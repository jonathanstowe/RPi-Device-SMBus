all: /home/jonathan/devel/perl6/RPi-Device-SMBus/lib/../resources/libraries/libi2chelper.so

/home/jonathan/devel/perl6/RPi-Device-SMBus/lib/../resources/libraries/libi2chelper.so: i2chelper.o
	gcc -shared -fPIC  -O3 -DNDEBUG -Wl,-rpath,/home/jonathan/.rakudobrew/moar-nom/install/lib -Wl,-rpath,/home/jonathan/.rakudobrew/moar-nom/install/share/perl6/site/lib -lm -lpthread -lrt -ldl -o /home/jonathan/devel/perl6/RPi-Device-SMBus/lib/../resources/libraries/libi2chelper.so i2chelper.o

i2chelper.o: i2chelper.c
	gcc -c -fPIC -Wdeclaration-after-statement -Werror=declaration-after-statement -O3 -DNDEBUG  -D_REENTRANT -D_FILE_OFFSET_BITS=64 -fPIC -o  i2chelper.o i2chelper.c
