; -----------------------------------------------------------------------------
;  Hello, world! for cZ80 step1 test program
; =============================================================================
;  Programmed by t.hara
; -----------------------------------------------------------------------------

PPI			:= 0xA8
VDP_PORT0	:= 0x98
VDP_PORT1	:= 0x99
VDP_PORT2	:= 0x9A
VDP_PORT3	:= 0x9B

			org		0x0000

			di
entry:
			ld		a, 0xF0
			out		[PPI], a
			ld		sp, 0xF000
			; VDP R#0 : Mode register 0 : SCREEN 1
			ld		bc, 0x0000
			call	wrtvdp
			; VDP R#1 : Mode register 1 : SCREEN 1
			ld		bc, 0x6301
			call	wrtvdp
			; VDP R#2 : Pattern Name Table = 0x1800
			ld		bc, 0x0602
			call	wrtvdp
			; VDP R#3 : Color Table = 0x2000
			ld		bc, 0x8003
			call	wrtvdp
			; VDP R#4 : Pattern Generator Table = 0x0000
			ld		bc, 0x0004
			call	wrtvdp
			; VDP R#5 : Sprite Attribute Table = 0x1B00
			ld		bc, 0x3605
			call	wrtvdp
			; VDP R#6 : Sptite Generator Table = 0x3800
			ld		bc, 0x0706
			call	wrtvdp
			; VDP R#7 : Set Color
			ld		bc, 0xF707
			call	wrtvdp
			; VDP R#8 : Mode Register 2
			ld		bc, 0x0808
			call	wrtvdp
			; VDP R#9 : Mode Register 3
			ld		bc, 0x0009
			call	wrtvdp
			; VRAM all clear
			ld		hl, 0x0000
			ld		bc, 0x4000
			xor		a, a
			call	filvrm
			; Color table
			ld		hl, 0x2000
			ld		bc, 32
			ld		a, 0xF4
			call	filvrm
			; Set Font Data
			ld		hl, msxfont
			ld		de, 0x0000
			ld		bc, 256 * 8
			call	ldirvm
			; Set Name Table
			ld		hl, name_table
			ld		de, 0x1800
			ld		bc, name_table_end - name_table
			call	ldirvm
			halt

; -----------------------------------------------------------------------------
;	WRTVDP
;	input:
;		C ... レジスタ番号
;		B ... 書き込む値
;	break:
;		A, b, c, f
; -----------------------------------------------------------------------------
			scope	wrtvdp
wrtvdp::
			ld		a, b
			out		[VDP_PORT1], a
			ld		a, c
			or		a, 0x80
			out		[VDP_PORT1], a
			ret
			endscope

; -----------------------------------------------------------------------------
;	SETWRT
;	input:
;		HL ... 書き込み用にセットする VRAM アドレス
;	break:
;		a, f
; -----------------------------------------------------------------------------
			scope	setwrt
setwrt::
			ld		a, l
			out		[VDP_PORT1], a
			ld		a, h
			and		a, 0x3F
			or		a, 0x40
			out		[VDP_PORT1], a
			ret
			endscope

; -----------------------------------------------------------------------------
;	FILVRM
;	input:
;		HL ... 塗りつぶす VRAM の先頭アドレス
;		BC ... 塗りつぶす BYTE数
;		A .... 塗りつぶす値
;	break:
;		a, b, c, f
; -----------------------------------------------------------------------------
			scope	filvrm
filvrm::
			push	af
			call	setwrt
			pop		af
			push	hl
			ld		l, a
	loop:
			ld		a, l
			out		[VDP_PORT0], a
			dec		bc
			ld		a, c
			or		a, b
			jr		nz, loop
			pop		hl
			ret
			endscope

; -----------------------------------------------------------------------------
;	LDIRVM
;	input:
;		HL ... 転送元の RAMアドレス
;		DE ... 転送先の VRAMアドレス
;		BC ... 転送する長さ
;	break:
;		すべて
; -----------------------------------------------------------------------------
			scope	ldirvm
ldirvm::
			ex		de, hl
			call	setwrt
			ex		de, hl
	loop:
			ld		a, [hl]
			inc		hl
			out		[VDP_PORT0], a
			dec		bc
			ld		a, c
			or		a, b
			jr		nz, loop
			ret
			endscope

s_start:
			db		"Start DEMO", 0x0D, 0x0A, 0
s_set_mode:
			db		"-- set SCREEN1", 0x0D, 0x0A, 0
s_set_color_palette:
			db		"-- set COLOR PALETTE", 0x0D, 0x0A, 0
s_clear_vram:
			db		"-- clear VRAM", 0x0D, 0x0A, 0
s_finish:
			db		"Finish.", 0x0D, 0x0A, 0

name_table::	;	 01234567890123456789012345678901
			db		"  MSX-BASIC version 5.0         "
			db		"  Copyright 2025 by Microsoft   "
			db		"  IoT Media Lab 2025            "
			db		"  MSX Licensing Corp 2025       "
			db		"  25271 Bytes free              "
			db		"  Disk BASIC version 3.00       "
			db		"  Ok                            "
			db		"  ", 255
name_table_end::

msxfont::
			binary_link		"msxfont.rom"
