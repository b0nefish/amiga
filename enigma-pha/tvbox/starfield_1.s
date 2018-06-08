
starfield_1

	;---- rotate stars arround box axes
	
	lea	stars1(pc),a0
	lea	stars1_boxrotated(pc),a1
	move.w	#nstars,d7
	jsr	rotate_box(pc)

	;---- plotter
	
	lea	stars1(pc),a0
	lea	stars1_boxrotated(pc),a1
	lea	vmuls(pc),a2
	move.l	triplebuffer(pc),a3
	lea	40*256(a3),a4

	;---- field 1

	move.w	#(nstars/3)-1,d7

.field1	movem.w	(a1),d0/d1
	move.b	d0,d2
	lsr.w	#3,d0
	add.w	d1,d1
	add.w	(a2,d1.w),d0
	not.b	d2
	bset	d2,(a4,d0.w)
	move.w	(a0),d0
	move.b	d0,d1
	subq.b	#3,d1
	add.b	d1,d1
	ext.w	d1
	asr.w	#1,d1
	move.w	d1,(a0)	
	lea	6(a0),a0
	lea	8(a1),a1
	dbf	d7,.field1

	;---- field2

	move.w	#(nstars/3)-1,d7

.field2	movem.w	(a1),d0/d1
	move.b	d0,d2
	lsr.w	#3,d0
	add.w	d1,d1
	add.w	(a2,d1.w),d0
	not.b	d2
	bset	d2,(a3,d0.w)
	bset	d2,(a4,d0.w)	
	move.w	(a0),d0
	move.b	d0,d1
	subq.b	#2,d1
	add.b	d1,d1
	ext.w	d1
	asr.w	#1,d1
	move.w	d1,(a0)	
	lea	6(a0),a0
	lea	8(a1),a1
	dbf	d7,.field2

	;---- field3

	move.w	#(nstars/3)-1,d7

.field3	movem.w	(a1),d0/d1
	move.b	d0,d2
	lsr.w	#3,d0
	add.w	d1,d1
	add.w	(a2,d1.w),d0
	not.b	d2
	bset	d2,(a3,d0.w)	
	move.w	(a0),d0
	move.b	d0,d1
	subq.b	#1,d1
	add.b	d1,d1
	ext.w	d1
	asr.w	#1,d1
	move.w	d1,(a0)	
	lea	6(a0),a0
	lea	8(a1),a1
	dbf	d7,.field3

	;----

	rts
	
stars1	ds.w	3*nstars
	dc.b	'sebo'
	
stars1_boxrotated
	ds.w	4*nstars
	dc.b	'sebo'
