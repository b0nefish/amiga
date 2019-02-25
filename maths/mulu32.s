	move.l	#70455,d0
	move.l	#13443,d1
	jsr	mulu32(pc)
	rts
	
	;----

mulu32	move.w	d1,d2
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
	rts
