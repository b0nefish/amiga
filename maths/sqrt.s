
	move.l	#255*255*2,d0

	;----

sqrt	moveq	#31,d1
	moveq	#0,d2
	moveq	#0,d3

.log2	btst	d1,d0
	dbne	d1,.log2	; log2(a)
	lsr.w	#1,d1
	addx.w	d3,d1
	bset	d1,d2		; x0 = 2^(log2(a)/2)
	
	REPT	2		; iterations
	move.l	d0,d1
	divu.w	d2,d1
	add.w	d1,d2
	lsr.w	#1,d2
	addx.w	d3,d2		; xi+1 = 1/2(xi + a/xi)	
	ENDR
	
	;----
	
	rts
	
