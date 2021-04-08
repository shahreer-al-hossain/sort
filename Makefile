# Makefile
.PHONY: clean
all: file.out

file.out: myfiles.S
	arm-linux-gnueabi-gcc $< -o $@ -ggdb3 -static

clean:
	rm -f file.out
