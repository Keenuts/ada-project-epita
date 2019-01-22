PROJECT=space_invader

all: ${PROJECT}

resources:
	gcc src/images.c -o images.o -c

${PROJECT}: resources
	gprbuild -XADL_BUILD=Debug -XADL_BUILD_CHECKS=Enabled -P ${PROJECT}.gpr

prove:
	gnatprove -P ${PROJECT}.gpr

flash:
	arm-eabi-objcopy -O binary obj/main image.bin
	st-flash --reset write image.bin 0x8000000

clean:
	$(RM) *.o image.bin
	$(RM) -r obj/
