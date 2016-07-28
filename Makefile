build: asm link fix
asm:
	rgbasm -v -o hello.o hello.asm
link: 
	rgblink -o hello.gb hello.o
fix:
	rgbfix -v hello.gb
clean:
	rm hello.o hello.gb
push:
	cp hello.gb "/Volumes/Heaps Cart/"
