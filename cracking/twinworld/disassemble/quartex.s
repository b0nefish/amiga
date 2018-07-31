
	; Quartex loader used in Twinworld crack

lc439a4	movem.l	d0-7/a0-6,-(a7)
	lea	lc439a4(pc),a5
	movea.l	a0,a2
	move.l	a0,$200(a5)
	add.l	d1,$200(a5)
	divu	#$16,d0
	move.w	d0,$208(a5)
	swap	d0
	cmpi.w	#$b,d0
	bge.s	lc439ce
	move.w	#1,$204(a5)
	bra.s	lc439d6
lc439ce	clr.w	$204(a5)
	subi.w	#$b,d0
lc439d6	move.w	d0,$20a(a5)

	lea	$bfd100,a4
	lea	$dff000,a6
	lea	$24(a6),a3
	move.w	#$8210,$96(a6)
	moveq	#0,d4
	moveq	#1,d7
	move.l	#$55555555,d6
	move.b	#$ff,(a4)
	bclr	#7,(a4)
	bsr	lc43aca
	bclr	#3,(a4)
	bsr	lc43aca
	bset	d7,(a4)
	bsr	lc43aca
	move.w	lc43ba8(pc),d0
	tst.b	d0
	beq.s	lc43a22
	bset	#2,(a4)
	bra.s	lc43a26
lc43a22	bclr	#2,(a4)
lc43a26	bsr	lc43aca
	tst.w	$1fe(a5)
	bge.s	lc43a38
	bsr	lc43aa0
	clr.w	$1fe(a5)
lc43a38	move.w	lc43bac(pc),d0
	cmp.w	lc43ba2(pc),d0
	beq.s	lc43a50
	blt.s	lc43a4a
	bsr	lc43aae
	bra.s	lc43a38
lc43a4a	bsr	lc43ab8
	bra.s	lc43a38
lc43a50	moveq	#0,d0
lc43a52	bsr	lc43ae0
	bsr	lc43b28
	cmpi.w	#1,$204(a5)
	beq.s	lc43a72
	move.w	d7,$204(a5)
	bset	#2,(a4)
	bsr	lc43aca
	bsr.s	lc43aae
	bra.s	lc43a7c
lc43a72	clr.w	$204(a5)
	bclr	#2,(a4)
	bsr.s	lc43aca
lc43a7c	adda.l	d5,a2
	cmpa.l	lc43ba4(pc),a2
	blt.s	lc43a52
	bset	#7,(a4)
	bset	#3,(a4)
	bsr.s	lc43aca
	bclr	#3,(a4)
	bsr.s	lc43aca
	bset	#3,(a4)
	movem.l	(a7)+,d0-7/a0-6
	rts
	
lc43a9e	bsr.s	lc43ab8
lc43aa0	btst	#4,$f01(a4)
	bne.s	lc43a9e
	clr.w	$1fe(a5)
	rts
	
lc43aae	bclr	d7,(a4)
	bsr.s	lc43ac2
	add.w	d7,$1fe(a5)
	rts
	
lc43ab8	bset	d7,(a4)
	bsr.s	lc43ac2
	sub.w	d7,$1fe(a5)
	rts
	
lc43ac2	bclr	d4,(a4)
	bset	d4,(a4)
	bsr.s	lc43aca
	rts
	
lc43aca	move.w	#$2710,d7
lc43ace	dbf	d7,lc43ace
	moveq	#1,d7
	rts
	
lc43ad6	btst	#5,$f01(a4)
	bne.s	lc43ad6
	rts
	
lc43ae0	move.w	#$9500,$9e(a6)
	move.w	#$4489,$7e(a6)
	bsr.s	lc43ad6
	move.w	#$4000,(a3)
	move.l	#$400,$20(a6)
	move.w	#$9b06,(a3)
	move.w	#$9b06,(a3)
	move.w	#2,$9c(a6)
	move.l	#$80000,d3
lc43b0e	move.w	$1e(a6),d2
	btst	d7,d2
	bne.s	lc43b1c
	sub.l	d7,d3
	bne.s	lc43b0e
	bra.s	lc43ae0
	
lc43b1c	move.w	#$4000,(a3)
	move.w	#$400,$9e(a6)
	rts
	
lc43b28	moveq	#$a,d0
	lea	$400,a0
	moveq	#0,d5
lc43b32	cmpi.w	#$4489,(a0)+
	bne.s	lc43b32
	cmpi.w	#$4489,(a0)
	bne.s	lc43b40
	addq.l	#2,a0
lc43b40	move.l	(a0)+,d1
	move.l	(a0)+,d2
	and.l	d6,d1
	and.l	d6,d2
	asl.l	d7,d1
	or.l	d2,d1
	andi.l	#$ff00,d1
	lsr.l	#8,d1
	cmp.w	lc43bae(pc),d1
	bmi.s	lc43b98
	sub.w	lc43bae(pc),d1
	mulu	#$200,d1
	add.l	a2,d1
	movea.l	d1,a1
	adda.l	#$30,a0
	moveq	#$7f,d1
	addi.l	#$200,d5
lc43b74	move.l	$200(a0),d2
	move.l	(a0)+,d3
	and.l	d6,d2
	and.l	d6,d3
	asl.l	d7,d3
	or.l	d3,d2
	moveq	#3,d3
lc43b84	cmpa.l	lc43ba4(pc),a1
	bpl	lc43b98
	rol.l	#8,d2
	move.b	d2,(a1)+
	dbf	d3,lc43b84
	dbf	d1,lc43b74
lc43b98	dbf	d0,lc43b32
	clr.w	$20a(a5)
	rts