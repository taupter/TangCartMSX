; -----------------------------------------------------------------------------
;  Hello, world! for cZ80 step1 test program
; =============================================================================
;  Programmed by t.hara
; -----------------------------------------------------------------------------

UART := 0x10

			org		0x0000

			di
			ld		sp, 0x7FFE
			ld		hl, s_hello_world
			call	puts
			halt

; -----------------------------------------------------------------------------
;	putc
;	input:
;		A ...... send byte
;	output:
;		none
;	break:
;		B, C, F
; -----------------------------------------------------------------------------
			scope	putc
putc::
			ld		c, UART
	wait_loop:
			in		b, [c]
			rr		b
			jr		c, wait_loop
			out		[c], a
			ret
			endscope

; -----------------------------------------------------------------------------
;	puts
;	input:
;		HL ...... target string address ( 0 terminated )
;	output:
;		HL ...... next address
;	break:
;		A, B, C, F
; -----------------------------------------------------------------------------
			scope	puts
puts::
			ld		a, [hl]
			inc		hl
			or		a, a
			ret		z
			call	putc
			jr		puts
			endscope

; -----------------------------------------------------------------------------
;	datas
; -----------------------------------------------------------------------------
s_hello_world::
			ds		"Hello, world!"
			db		0x0D, 0x0A, 0
