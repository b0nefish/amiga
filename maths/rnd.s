
rnd	lea	list(pc),a1
	move.w	#100-1,d7

.loop	lea	seed(pc),a0
	move.l	#$41c64e6d,d1	; a
	
	move.l	(a0),d0		; Xn	
	move.w	d1,d2
	mulu	d0,d2
	move.l	d1,d3
	swap	d3
	mulu	d0,d3
	swap	d3
	clr.w	d3
	add.l	d3,d2
	swap	d0
	mulu	d1,d0
	swap	d0
	clr.w	d0
	add.l	d2,d0
	addi.l	#$3039,d0	; c
	move.l	d0,(a0)
	
	swap	d0
	andi.l	#$7fff,d0
	divu	#128,d0
	swap	d0
	move.w	d0,(a1)+	; Xn+1 = (aXn + c) mod 128
	
	dbf	d7,.loop
	rts

	;----

seed	ds.l	1
list	ds.w	100		
