#!/bin/bash
eabi-as irq.s -o irq.o
eabi-ld -T irqld.ld irq.o -o ex.elf
eabi-bin ex.elf ex
qemu ex
