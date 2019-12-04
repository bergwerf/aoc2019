#!/bin/bash

# Compile and link (GCC automatically includes libc)
rm day4
nasm -f elf64 day4.asm -o day4.o
gcc day4.o -no-pie -o day4

./day4