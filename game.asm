; Patrick Stalcup
; 2016

INCLUDE "gbhw.inc" 
INCLUDE "game.inc"

; IRQs
SECTION	"Vblank",HOME[$0040]
	ld [hl], 1
	reti
SECTION	"LCDC",HOME[$0048]
	reti
SECTION	"Timer_Overflow",HOME[$0050]
	;ld [hl], 1
	reti
SECTION	"Serial",HOME[$0058]
	reti
SECTION	"p1thru4",HOME[$0060]
	reti

; boot loader jumps here
SECTION "start",HOME[$0100]
	nop
	jp begin
	ROM_HEADER	ROM_NOMBC, ROM_SIZE_32KBYTE, RAM_SIZE_0KBYTE

begin:
; set background palatte
	ld a, %11100100
	ld [rBGP], a
	ld [rOBP0], a
; set window location
	ld a, 8
	ld [rSCX], a
	ld a, 16
	ld [rSCY], a
; enable interupts
	ld a, %00000101
	ld [rIE], a
; turn off LCD
	ld a, [rLCDC]
	rlca
	jr nc, lcd_load
.lcd_load_wait
	ld a, [rLY]
	cp a, 145
	jr nz, .lcd_load_wait
.lcd_load
	ld a, [rLCDC]
	res 7, a
	ld [rLCDC], a	
; init tile data
	ld b, 16
	ld hl, $8000
	ld de, sprite_tile
.tile_load
	ld a, [de]
	ld [hl], a
	inc hl
	inc de
	dec b
	jr nz, .tile_load
; init OAM
	ld b, 4
	ld hl, $FE00
	ld de, sprite_flag
.oam_load
	ld a, [de]
	ld [hl], a
	inc hl
	inc de
	dec b
	jr nz, .oam_load
	ld b, 156; 4 * 39
.oam_zero
	ld [hl], 0
	inc hl
	dec b
	jr nz, .oam_zero
	;; zero VRAM
	; init LCD
	ld a, %10000010
	ld [rLCDC], a
	ld a, %11110000
	ld [rSTAT], a
	xor a
.init_memory
	ld hl, vblank_flag
	ld [hl], 0
.init_timers
	;ld [rTAC], $04
	;ld [rTMA], $00
main:
	ei
	xor a
	ld hl, vblank_flag
	halt
	cp a, [hl]
	jr z, main	
	ld [hl], a
	ld a, %00101111
	ld [rP1], a
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	ld b, a
.right:
	bit 0, b
	jr nz, .left
	ld hl, $fe01
	ld a, [hl]
	inc a
	ld [hl], a
.left:
	bit 1, b
	jr nz, .up
	ld hl, $fe01
	ld a, [hl]
	dec a
	ld [hl], a
.up:
	bit 2, b
	jr nz, .down 
	ld hl, $fe00
	ld a, [hl]
	dec a
	ld [hl], a
.down:
	bit 3, b
	jr nz, .input_done
	ld b, a
	ld hl, $fe00
	ld a, [hl]
	inc a
	ld [hl], a
.input_done:
	;ld a, $F1
	;ld [rDMA], a
	jp main

sprite_flag:
	; x position
	DB $20
	; y position
	DB $20
	; tile number
	DB $00
	;sprite flags - default flags
	DB %00000000

sprite_tile:
	; raw tile data
	DB %00111100 
	DB %00111100
	DB %01111010 
	DB %01000110
	DB %01100010 
	DB %01011110
	DB %01100010 
	DB %01011110
	DB %01100010 
	DB %01011110
	DB %01100010 
	DB %01011110
	DB %01100010 
	DB %01011110
	DB %00111100 
	DB %00111100
	
