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
	ld a, 16
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
	ld b, 32
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
	ld b, 4 * enemy_sprite_count + 4
	ld hl, $fe00
	ld de, sprite_flag
.oam_load
	ld a, [de]
	ld [hl], a
	inc hl
	inc de
	dec b
	jr nz, .oam_load
	ld b, 4 * 39; 4 * 39
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
	ld hl, player_sprite_x
	inc [hl]
.left:
	bit 1, b
	jr nz, .up
	ld hl, player_sprite_x
	dec [hl]
.up:
	bit 2, b
	jr nz, .down 
	ld hl, player_sprite_y
	dec [hl]
.down:
	bit 3, b
	jr nz, .input_done
	ld hl, player_sprite_y
	inc [hl]
.input_done:
.enemy_move:
	ld hl, $fe04
	ld b, 3
.enemy_move_loop:
	ld a, [hl]
	add a, 4
	ld [hl], a
	ld a, 4
	add l
	ld l, a
	dec b
	jr nz, .enemy_move_loop
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
enemy_flags:
	; x position
	DB $30
	; y position
	DB $30
	; tile number
	DB $01
	;sprite flags - default flags
	DB %00000000
	; x position
	DB $40
	; y position
	DB $40
	; tile number
	DB $01
	;sprite flags - default flags
	DB %00000000
	; x position
	DB $50
	; y position
	DB $50
	; tile number
	DB $01
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
	
enemy_tile:
	DB %00111100
	DB %01111110
	DB %00111100
	DB %01111110
	DB %00111100
	DB %01111110
	DB %00111100
	DB %00111100
	DB %00111100
	DB %00111100
	DB %00111100
	DB %00111100
	DB %00111100
	DB %00111100
	DB %00111100
	DB %00111100
	DB %00111100
	DB %00111100