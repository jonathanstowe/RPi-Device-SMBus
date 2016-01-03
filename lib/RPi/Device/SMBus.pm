use v6;
use NativeCall;

=begin pod

=end pod

class RPi::Device::SMBus {

    use NativeHelpers::Array;

    class X::Open is Exception {
        has Str $.message;
    }

    class X::IO is Exception {
        has Str $.message;
    }

    constant BLOCK_MAX = 32;
    constant HELPER = %?RESOURCES<libraries/i2chelper>.Str;

    subset I2C-Address of Int where * < 128;
    subset DevicePath  of Str where { $_.IO ~~ :e };

    subset Byte    of Int where   {  $_ >= 0 && $_ <= 255 };
    subset Word    of Int where   {  $_ >= 0 && $_ < 65536 };
    subset Command of Int where   {  $_ >= 0 && $_ <= 255 };
    subset Block   of Array where { $_.elems <= 32 && all($_.list) < 256 };

    has I2C-Address $.address is required;
    has DevicePath  $.device  is required;

    has Int $!fd;

    method !fd() returns Int {
        if not $!fd.defined {
            $!fd = self!open($!device, $!address);
        }
        $!fd;
    }

    sub rpi_dev_smbus_open(Str $file, int32 $address) returns int32 is native(HELPER) { * }

    method !open(Str $file, Int $address ) returns Int {
        explicitly-manage($file);
        my Int $fd = rpi_dev_smbus_open($file, $address);
        if $fd < 0 {
            X::Open.new(message => "Error opening the device").throw;
        }
        $fd;
    }

    sub rpi_dev_smbus_write_quick(int32 $file, uint8 $value) returns  int32 is native(HELPER) { * }

    method write-quick(Byte $value) returns Int {
        rpi_dev_smbus_write_quick(self!fd, $value);
    }

    sub rpi_dev_smbus_read_byte(int32 $file) returns  int32 is native(HELPER) { * }

    method read-byte() returns Int {
        rpi_dev_smbus_read_byte(self!fd);
    }

    sub rpi_dev_smbus_write_byte(int32 $file, uint8 $value) returns  int32 is native(HELPER) { * }

    method write-byte(Byte $value) returns Int {
        rpi_dev_smbus_write_byte(self!fd, $value);
    }

    sub rpi_dev_smbus_read_byte_data(int32 $file, uint8 $command) returns  int32 is native(HELPER) { * }

    method read-byte-data(Command $command) returns Int {
        rpi_dev_smbus_read_byte_data(self!fd, $command);
    }

    sub rpi_dev_smbus_write_byte_data(int32 $file, uint8 $command, uint8 $value) returns  int32 is native(HELPER) { * }

    method write-byte-data(Command $command, Byte $value) returns Int {
        rpi_dev_smbus_write_byte_data(self!fd, $command, $value);
    }

    sub rpi_dev_smbus_read_word_data(int32 $file, uint8 $command) returns  int32 is native(HELPER) { * }

    method read-word-data(Command $command) returns Int {
        rpi_dev_smbus_read_word_data(self!fd, $command);
    }

    sub rpi_dev_smbus_write_word_data(int32 $file, uint8 $command, uint16 $value) returns  int32 is native(HELPER) { * }

    method write-word-data(Command $command, Word $value) returns Int {
        rpi_dev_smbus_write_word_data(self!fd, $command, $value);
    }

    sub rpi_dev_smbus_process_call(int32 $file, uint8 $command, uint16 $value) returns  int32 is native(HELPER) { * }

    # writes a Word and returns a value
    method process-call(Command $command, Word $value) returns Int {
        rpi_dev_smbus_write_word_data(self!fd, $command, $value);
    }

    sub rpi_dev_smbus_read_block_data(int32 $file, uint8 $command, CArray[uint8] $values) returns  int32 is native(HELPER) { * }

    multi method read-block-data(Command $command) returns Block {
        my CArray[uint8] $out-buf = CArray[uint].new;
        $out-buf[BLOCK_MAX + 1] = 0;

        my $len = rpi_dev_smbus_read_block_data(self!fd, $command, $out-buf);

        if $len < 0 {
            X::IO.new(message => "'read_block_data' failed").throw;
        }

        my @array = copy-to-array($out-buf, $len + 1);
        # this is the actual length
        my $ll = @array.shift;
        @array;
    }

    sub rpi_dev_smbus_write_block_data(int32 $file, uint8 $command, uint8 $length, CArray[uint8] $values) returns  int32 is native(HELPER) { * }

    multi method write-block-data(Command $command, Block $block) returns Int {
        my CArray[uint8] $buf = copy-to-carray($block, uint8);
        rpi_dev_smbus_write_block_data(self!fd, $command, $block.elems, $buf);
    }

    sub rpi_dev_smbus_read_i2c_block_data(int32 $file, uint8 $command, uint8 $length, CArray[uint8] $values) returns  int32 is native(HELPER) { * }

    multi method read-i2c-block-data(Command $command, Int $length) returns Block {
        my CArray[uint8] $out-buf = CArray[uint].new;
        $out-buf[BLOCK_MAX + 1] = 0;

        my $len = rpi_dev_smbus_read_i2c_block_data(self!fd, $command, $length, $out-buf);

        if $len < 0 {
            X::IO.new(message => "'read_i2c_block_data' failed").throw;
        }

        my @array = copy-to-array($out-buf, $len + 1);
        # this is the actual length
        my $ll = @array.shift;
        @array;
    }

    sub rpi_dev_smbus_write_i2c_block_data(int32 $file, uint8 $command, uint8 $length, CArray[uint8] $values) returns  int32 is native(HELPER) { * }

    multi method write-i2c-block-data(Command $command, Block $block ) returns Int {
        my CArray[uint8] $buf = copy-to-carray($block, uint8);
        rpi_dev_smbus_write_i2c_block_data(self!fd, $command, $block.elems, $buf);
    }

    sub rpi_dev_smbus_block_process_call(int32 $file, uint8 $command, uint8 $length, CArray[uint8] $values) returns  int32 is native(HELPER) { * }

    multi method block-process-call(Command $command, Block $block) returns Block {
        my CArray[uint8] $buf = copy-to-carray($block, uint8);
        my $len = rpi_dev_smbus_block_process_call(self!fd, $command, $block.elems, $buf);
        if $len < 0 {
            X::IO.new(message => "'block_process_call' failed").throw;
        }

        my @array = copy-to-array($buf, $len + 1);
        # this is the actual length
        my $ll = @array.shift;
        @array;

    }

}
# vim: expandtab shiftwidth=4 ft=perl6
