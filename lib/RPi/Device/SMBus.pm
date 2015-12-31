use v6;
use NativeCall;

=begin pod

=end pod

class RPi::Device::SMBus {

    class X::Open is Exception {
        has Str $.message;
    }

    constant HELPER = %?RESOURCES<libraries/i2chelper>.Str;

    subset I2C-Address of Int where * < 128;
    subset DevicePath  of Str where { $_.IO ~~ :e };

    has I2C-Address $.address is required;
    has DevicePath  $.device  is required;

    sub rpi_dev_smbus_open(Str $file, int32 $address) returns int32 is native(HELPER) { * }

    method !open(Str $file, Int $address ) returns Int {
        implicitly-manage($file);
        my Int $fd = rpi_dev_smbus_open($file, $address);
        if $fd < 0 {
            X::Open.new(message => "Error opening the device").throw;
        }
        $fd;
    }

    sub rpi_dev_smbus_write_quick(int32 $file, uint8 $value) returns  int32 is native(HELPER) { * }
    sub rpi_dev_smbus_read_byte(int32 $file) returns  int32 is native(HELPER) { * }
    sub rpi_dev_smbus_write_byte(int32 $file, uint8 $value) returns  int32 is native(HELPER) { * }
    sub rpi_dev_smbus_read_byte_data(int32 $file, uint8 $command) returns  int32 is native(HELPER) { * }
    sub rpi_dev_smbus_write_byte_data(int32 $file, uint8 $command, uint8 $value) returns  int32 is native(HELPER) { * }
    sub rpi_dev_smbus_read_word_data(int32 $file, uint8 $command) returns  int32 is native(HELPER) { * }
    sub rpi_dev_smbus_write_word_data(int32 $file, uint8 $command, uint16 $value) returns  int32 is native(HELPER) { * }
    sub rpi_dev_smbus_process_call(int32 $file, uint8 $command, uint16 $value) returns  int32 is native(HELPER) { * }
    sub rpi_dev_smbus_read_block_data(int32 $file, uint8 $command, CArray[uint8] $values) returns  int32 is native(HELPER) { * }
    sub rpi_dev_smbus_write_block_data(int32 $file, uint8 $command, uint8 $length, CArray[uint8] $values) returns  int32 is native(HELPER) { * }
    sub rpi_dev_smbus_read_i2c_block_data(int32 $file, uint8 $command, uint8 $length, CArray[uint8] $values) returns  int32 is native(HELPER) { * }
    sub rpi_dev_smbus_write_i2c_block_data(int32 $file, uint8 $command, uint8 $length, CArray[uint8] $values) returns  int32 is native(HELPER) { * }
    sub rpi_dev_smbus_block_process_call(int32 $file, uint8 $command, uint8 $length, CArray[uint8] $values) returns  int32 is native(HELPER) { * }
}
# vim: expandtab shiftwidth=4 ft=perl6
