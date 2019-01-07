
	;----
	; Ice Packer Decruncher
	; a0 = ice packed file

	movem.l	d0-a6,-(sp)

	bsr	lc45882
	cmpi.l	#$49636521,d0
	bne.b	lc4587c

	bsr.b	lc45882
	lea	-8(a0,d0.l),a5
	bsr.b	lc45882
	move.l	d0,(a7)
	lea	$6c(a0),a4
	movea.l	a4,a6
	adda.l	d0,a6
	movea.l	a6,a3
	movea.l	a6,a1
	lea	temp(pc),a2
	moveq	#$77,d0
lc45850	move.b	-(a1),-(a2)
	dbf	d0,lc45850
	bsr	lc458ba
	bsr.b	lc4588e
	move.l	(a7),d0
	lea	-$78(a4),a1
lc45862	move.b	(a4)+,(a1)+
	dbf	d0,lc45862
	subi.l	#$10000,d0
	bpl.b	lc45862
	moveq	#$77,d0
	lea	temp(pc),a2
lc45876	move.b	-(a2),-(a3)
	dbf	d0,lc45876

lc4587c	movem.l	(sp)+,d0-a6
	rts
	
lc45882	moveq	#3,d1
lc45884	lsl.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,lc45884
	rts
	
lc4588e	bsr.b	lc458e6
	bcc.b	lc458b4
	moveq	#0,d1
	bsr.b	lc458e6
	bcc.b	lc458ae
	lea	lc45992(pc),a1 ; ?
	moveq	#4,d3
lc4589e	move.l	-(a1),d0
	bsr.b	lc4590c
	swap	d0
	cmp.w	d0,d1
	dbne	d3,lc4589e
	add.l	$14(a1),d1
lc458ae	move.b	-(a5),-(a6)
	dbf	d1,lc458ae
lc458b4	cmpa.l	a4,a6
	bgt.b	lc4591a
	rts
	
lc458ba	moveq	#3,d0
lc458bc	move.b	-(a5),d7
	ror.l	#8,d7
	dbf	d0,lc458bc
	rts
	
lc458c6	move.w	a5,d7
	btst	#0,d7
	bne.b	lc458d4
	move.l	-(a5),d7
	addx.l	d7,d7
	bra.b	lc45912
lc458d4	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	bra.b	lc45912
lc458e6	add.l	d7,d7
	beq.b	lc458ec
	rts
	
lc458ec	move.w	a5,d7
	btst	#0,d7
	bne.b	lc458fa
	move.l	-(a5),d7
	addx.l	d7,d7
	rts
	
lc458fa	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	rts
	
lc4590c	moveq	#0,d1
lc4590e	add.l	d7,d7
	beq.b	lc458c6
lc45912	addx.w	d1,d1
	dbf	d0,lc4590e
	rts
	
lc4591a	lea	lc459a6(pc),a1 ; ?
	moveq	#3,d2
lc45920	bsr.b	lc458e6
	dbcc	d2,lc45920
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.b	lc45934
	bsr.b	lc4590c
lc45934	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.b	lc4595a
	lea	lc459b0(pc),a1 ; ?
	moveq	#1,d2
lc45942	bsr.b	lc458e6
	dbcc	d2,lc45942
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.b	lc4590c
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bra.b	lc4596c
lc4595a	moveq	#0,d1
	moveq	#5,d0
	moveq	#0,d2
	bsr.b	lc458e6
	bcc.b	lc45968
	moveq	#8,d0
	moveq	#$40,d2
lc45968	bsr.b	lc4590c
	add.w	d2,d1
lc4596c	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
lc45974	move.b	-(a1),-(a6)
	dbf	d4,lc45974
	bra	lc4588e

	;----

temp	ds.b	120
