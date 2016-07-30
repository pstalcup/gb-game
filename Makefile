build: asm link fix
asm:
	rgbasm -v -o game.o game.asm
link: 
	rgblink -o game.gb game.o
fix:
	rgbfix -v game.gb
clean:
	rm game.o game.gb
push: build
	cp game.gb "/Volumes/Heaps Cart/"
launch: build
	wine ../bgb/bgb.exe game.gb