#!/bin/bash

arm-eabi-objcopy -O binary obj/main image.bin
st-flash --reset write image.bin 0x8000000
