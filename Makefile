PREFIX=/usr/avr
INCLUDE=$(PREFIX)/include
INCLUDE_POLOLU=$(INCLUDE)/pololu
LIB=$(PREFIX)/lib
ZIPDIR=lib_zipfiles
SRC_ZIPFILE=$(ZIPDIR)/libpololu-avr-$(shell date +%y%m%d).src.zip
BIN_ZIPFILE=$(ZIPDIR)/libpololu-avr-$(shell date +%y%m%d).zip
ARDUINO_ZIPFILE=$(ZIPDIR)/libpololu-arduino-$(shell date +%y%m%d).zip
ARDUINO_QTR_ZIPFILE=$(ZIPDIR)/PololuQTRSensors-$(shell date +%y%m%d).zip

CFLAGS=-g -Wall -mcall-prologues -mmcu=atmega168 -DLIB_POLOLU -ffunction-sections -Os
CPP=avr-g++
CC=avr-gcc

LIBRARY_OBJECT_FILES=\
	src/OrangutanMotors/OrangutanMotors.o \
	src/OrangutanBuzzer/OrangutanBuzzer.o \
	src/OrangutanPushbuttons/OrangutanPushbuttons.o \
	src/OrangutanLCD/OrangutanLCD.o \
	src/OrangutanLEDs/OrangutanLEDs.o \
	src/OrangutanAnalog/OrangutanAnalog.o \
	src/PololuQTRSensors/PololuQTRSensors.o \
	src/Pololu3pi/Pololu3pi.o \
	src/PololuQTRSensors/PololuQTRSensors.o \
	src/OrangutanResources/OrangutanResources.o \
	src/OrangutanTime/OrangutanTime.o

OBJ2HEX=avr-objcopy 
LDFLAGS=-Wl,-gc-sections -L. -lpololu -lm

libpololu.a: $(LIBRARY_OBJECT_FILES)
	avr-ar rs libpololu.a $(LIBRARY_OBJECT_FILES)

%.o:%.cpp
	$(CPP) $(CFLAGS) $< -c -o $@

clean:
	rm -f $(LIBRARY_OBJECT_FILES) *.a *.hex *.obj

%.hex : %.obj
	$(OBJ2HEX) -R .eeprom -O ihex $< $@

install: libpololu.a
	install -d $(LIB)
	install -d $(INCLUDE_POLOLU)
	install -t $(LIB) libpololu.a
	install -t $(INCLUDE_POLOLU) pololu/*.h
	install -t $(INCLUDE_POLOLU) pololu/orangutan

ZIP_EXCLUDES=\*.o .svn/\* \*/.svn/\* \*.hex \*.zip libpololu-avr/arduino_zipfiles/ arduino_zipfiles/\* \*/lib_zipfiles/\* \*.elf \*.eep \*.lss \*.o.d libpololu-avr/libpololu-avr/\* libpololu-avr/extra/\* libpololu-avr/graphics/\* \*.map libpololu-avr/test/*

ARDUINO_EXCLUDES=libpololu-arduino/OrangutanTime/\*

zip: libpololu.a
	mkdir -p $(ZIPDIR)
	rm -f $(SRC_ZIPFILE)
	rm -f $(BIN_ZIPFILE)
	rm -f $(ARDUINO_ZIPFILE)
	rm -f $(ARDUINO_QTR_ZIPFILE)
	ln -s extra/src libpololu-avr
	zip -rq $(SRC_ZIPFILE) libpololu-avr -x $(ZIP_EXCLUDES)
	rm libpololu-avr
	ln -s . libpololu-avr
	zip -rq $(SRC_ZIPFILE) libpololu-avr -x $(ZIP_EXCLUDES) \*.a
	rm libpololu-avr
	ln -s extra/bin libpololu-avr
	zip -rq $(BIN_ZIPFILE) libpololu-avr -x $(ZIP_EXCLUDES)
	rm libpololu-avr
	ln -s . libpololu-avr
	zip -rq $(BIN_ZIPFILE) libpololu-avr/README.txt libpololu-avr/libpololu.a libpololu-avr/pololu libpololu-avr/test libpololu-avr/examples -x $(ZIP_EXCLUDES)
	rm libpololu-avr
	ln -s src libpololu-arduino
	zip -rq $(ARDUINO_ZIPFILE) README-Arduino.txt libpololu-arduino -x $(ZIP_EXCLUDES) -x $(ARDUINO_EXCLUDES)
	rm libpololu-arduino
	ln -s src/PololuQTRSensors .
	zip -rq $(ARDUINO_QTR_ZIPFILE) PololuQTRSensors -x $(ZIP_EXCLUDES) -x $(ARDUINO_EXCLUDES)
	rm PololuQTRSensors