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

	;----

boot	dc.b	'DOS',0
	ds.l	1
	dc.l	880

	;----

	move.w	#2,$1c(a1)
	move.l	#1024*6,$24(a1)
	move.l	#$43400,$28(a1)
	move.l	#(512*11*2),$2c(a1)
	
	move.l	4.w,a6
	jsr	-456(a6)	; doio
	
	;---- take system
	
	jsr	-132(a6)	; forbid
	jsr	-120(a6)	; disable
	jsr	-150(a6)	; superstat

	;----

	lea	$dff000,a6
	move.w	#$7fff,$9a(a6)
	move.w	#$7fff,$96(a6)
	move.w	#$7,$180(a6)

	lea	$400,sp
	jmp	$43400

	;----

padding	ds.b	(512*2)-(padding-boot)
end
