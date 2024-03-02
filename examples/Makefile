DIRS := 01-lib-battery 02-dll-engine 03-dll-computer 04-dll-car 05-exe-peugeot

all clean:
	+@for d in $(DIRS); do make -C $$d -s --no-print-directory $@; done
