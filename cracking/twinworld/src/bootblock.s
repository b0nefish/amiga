check	lea 	boot(pc),a0
        move.l	a0,a1
	clr.l	4(a0)
        move.w	#(1024/4)-1,d7
        moveq	#0,d0
        moveq	#0,d1
.loop	add.l	(a0)+,d0
	addx.l	d1,d0
	dbf	d7,.loop
        not.l	d0
	move.l	d0,4(a1)
        rts

	;---- Twinworld bootblock

boot	dc.b	'DOS',0
	ds.l	1
	dc.l	880

	;----

	move.w	#2,$1c(a1)
	move.l	#45000,$24(a1)	; length
	move.l	#$6520,$28(a1)	; target
	move.l	#512*2,$2c(a1)	; offset
	
	move.l	4.w,a6
	jsr	-456(a6)	; doio	
	jsr	-132(a6)	; forbid
	jsr	-120(a6)	; disable
	jsr	-150(a6)	; superstate

	;----

	lea	$7fff0,sp
	move.w	#$7fff,$dff096
	move.w	#$7fff,$dff09a
	move.w	#$7fff,$dff09c

	;----

	jmp	$6520		; bootstrap twinworld

	;----

padding	ds.b	(512*2)-(padding-boot)
end
