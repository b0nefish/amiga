; $50000

	lea	lc4d398(pc),a0
	move.l	a0,$80
	trap	#0
	
lc4d398	lea	$7fff0,a7
	lea	lc4d3ba(pc),a0
	lea	$5d20,a1
	move.l	#$19f,d0
lc4d3ae	move.l	(a0)+,(a1)+
	dbf	d0,lc4d3ae
	jmp	$5d20
	
	;----
	
lc4d3ba	move.w	#$7fff,$dff096
	move.w	#$7fff,$dff09a
	move.w	#$7fff,$dff09c
	
	lea	$6520,a0
	move.l	#$1e6b7,d0
lc4d3de	move.l	#0,(a0)+
	dbf	d0,lc4d3de
	
	move.w	#$8210,$dff096
	
lc4d3f0	moveq	#0,d0
	bsr	lc4d42a
	
	lea	$6520,a0
	move.l	#1,d0
	move.l	#$d2f0,d1
	moveq	#0,d2
	bsr	lc4d91a ; load()
	
	cmp.l	#0,d0
	beq	lc4d422
	
	bsr	lc4d4ea
	jmp	$6520
	
lc4d422	bsr	lc4d5e8
	bra	lc4d3f0
lc4d42a	bsr	lc4d456
	bsr	lc4d4c2
	bsr	lc4d48e
	bsr	lc4d5e8
	rts
	
	bsr	lc4d5e8
	bsr	lc4d4ea
	rts
	
lc4d446	ori.b	#$78,$bfd100
	nop
	nop
	nop
	rts
	
lc4d456	bsr	lc4d446
	cmpi.l	#3,d0
	bhi	lc4d476
	addq.l	#3,d0
	bclr	d0,$bfd100
	nop
	nop
	nop
	moveq	#1,d0
	rts
	
lc4d476	moveq	#0,d0
	rts
	
	btst	#3,$bfe001
	bne	lc4d48a
	moveq	#1,d0
	rts
	
lc4d48a	moveq	#0,d0
	rts
	
lc4d48e	nop
	nop
	nop
	btst	#5,$bfe001
	bne	lc4d48e
	rts
	
lc4d4a2	bclr	#2,$bfd100
	nop
	nop
	nop
	rts
	
lc4d4b2	bset	#2,$bfd100
	nop
	nop
	nop
	rts
	
lc4d4c2	movem.l	d0/a5,-(a7)
	lea	$bfd000,a5
	move.b	$100(a5),d0
	bsr	lc4d446
	bclr	#7,$100(a5)
	nop
	nop
	nop
	move.b	d0,$100(a5)
	movem.l	(a7)+,d0/a5
	rts
	
lc4d4ea	movem.l	d0/a5,-(a7)
	lea	$bfd000,a5
	move.b	$100(a5),d0
	bsr	lc4d446
	bset	#7,$100(a5)
	nop
	nop
	nop
	move.b	d0,$100(a5)
	movem.l	(a7)+,d0/a5
	rts
	
lc4d512	movem.l	d0,-(a7)
	bset	#1,$bfd100
	nop
	nop
	nop
	bclr	#0,$bfd100
	nop
	nop
	nop
	bset	#0,$bfd100
	nop
	nop
	nop
	move.l	#$c00,d0
lc4d546	nop
	dbf	d0,lc4d546
	movem.l	(a7)+,d0
	rts
	
lc4d552	movem.l	d0,-(a7)
	bclr	#1,$bfd100
	nop
	nop
	nop
	bclr	#0,$bfd100
	nop
	nop
	nop
	bset	#0,$bfd100
	nop
	nop
	nop
	move.l	#$c00,d0
lc4d586	nop
	dbf	d0,lc4d586
	movem.l	(a7)+,d0
	rts
	
lc4d592	andi.l	#$ff,d0
	subq.l	#1,d0
lc4d59a	bsr	lc4d552
	dbf	d0,lc4d59a
	rts
	
lc4d5a4	andi.l	#$ff,d0
	subq.l	#1,d0
lc4d5ac	bsr	lc4d512
	dbf	d0,lc4d5ac
	rts
	
lc4d5b6	movem.l	d1,-(a7)
	moveq	#$64,d1
lc4d5bc	btst	#4,$bfe001
	beq	lc4d5d8
	bsr	lc4d512
	dbf	d1,lc4d5bc
	moveq	#0,d0
	movem.l	(a7)+,d1
	rts
	
lc4d5d8	move.b	#0,$5d00
	moveq	#1,d0
	movem.l	(a7)+,d1
	rts
	
lc4d5e8	bsr	lc4d5b6
	cmp.l	#0,d0
	beq	lc4d606
	bsr	lc4d4a2
	move.b	#0,$5d02
	moveq	#1,d0
	rts
	
lc4d606	moveq	#0,d0
	rts
	
lc4d60a	movem.l	d1-2,-(a7)
	cmp.b	$5d00,d0
	beq	lc4d642
	cmp.b	#$4f,d0
	bhi	lc4d63a
	tst.b	d0
	beq	lc4d64a
	cmp.b	$5d00,d0
	bmi	lc4d65c
	cmp.b	$5d00,d0
	bpl	lc4d676
lc4d63a	moveq	#0,d0
	movem.l	(a7)+,d1-2
	rts
	
lc4d642	moveq	#1,d0
	movem.l	(a7)+,d1-2
	rts
	
lc4d64a	bsr	lc4d5b6
	cmp.l	#1,d0
	beq	lc4d642
	bra	lc4d63a
lc4d65c	move.b	d0,d2
	move.b	$5d00,d1
	sub.b	d0,d1
	move.b	d1,d0
	bsr	lc4d5a4
	move.b	d2,$5d00
	bra	lc4d642
lc4d676	move.b	d0,d2
	sub.b	$5d00,d0
	bsr	lc4d592
	move.b	d2,$5d00
	bra	lc4d642
lc4d68c	movem.l	d1-2,-(a7)
	cmp.b	#$9f,d0
	bhi	lc4d6c8
	cmp.b	#$4f,d0
	bhi	lc4d6e2
	tst.b	d0
	beq	lc4d6d0
	move.b	d0,d2
	bsr	lc4d4a2
	bsr	lc4d60a
	cmp.l	#0,d0
	beq	lc4d6c8
	move.b	d2,$5d02
lc4d6c0	moveq	#1,d0
	movem.l	(a7)+,d1-2
	rts
	
lc4d6c8	moveq	#0,d0
	movem.l	(a7)+,d1-2
	rts
	
lc4d6d0	bsr	lc4d5e8
	cmp.l	#1,d0
	beq	lc4d6c0
	bra	lc4d6c8
lc4d6e2	move.b	d0,d2
	bsr	lc4d4b2
	subi.b	#$50,d0
	bsr	lc4d60a
	cmp.l	#0,d0
	beq	lc4d6c8
	move.b	d2,$5d02
	bra	lc4d6c0
lc4d704	movem.l	d1-2/d7/a0-2,-(a7)
	move.l	d0,d7
	andi.l	#$ff,d7
	bsr	lc4d8fc
	lea	$400,a1
	lea	$10b0(a1),a1
	move.w	#$5542,(a1)+
	move.w	#$aaaa,d0
	btst	#0,-1(a1)
	beq	lc4d734
	move.w	#$2aaa,d0
lc4d734	move.w	d0,(a1)+
	move.b	d7,(a1)+
	move.b	#1,(a1)+
	move.w	#0,(a1)+
	move.l	#0,(a1)+
	lea	$400,a0
	lea	$10b0(a0),a0
	move.l	4(a0),d0
	move.l	d0,d1
	andi.l	#$55555555,d1
	lsr.l	#1,d0
	andi.l	#$55555555,d0
	move.l	d0,4(a0)
	move.l	d1,8(a0)
	lea	$c(a0),a2
	lea	$4500,a1
	move.l	#$5e3,d7
lc4d77c	move.l	(a1)+,d0
	move.l	d0,d1
	andi.l	#$55555555,d1
	lsr.l	#1,d0
	andi.l	#$55555555,d0
	move.l	d0,(a2)+
	move.l	d1,(a2)+
	dbf	d7,lc4d77c
	lea	$400,a0
	lea	$10b4(a0),a0
	move.w	#$1793,d7
lc4d7a4	move.w	(a0),d0
	move.w	d0,d2
	eori.w	#$5555,d0
	move.w	d0,d1
	add.w	d0,d0
	lsr.w	#1,d1
	bset	#$f,d1
	and.w	d1,d0
	or.w	d2,d0
	btst	#0,-1(a0)
	beq	lc4d7c8
	bclr	#$f,d0
lc4d7c8	move.w	d0,(a0)+
	dbf	d7,lc4d7a4
	movem.l	(a7)+,d1-2/d7/a0-2
	rts
	
lc4d7d4	movem.l	d1-2/d6-7/a1,-(a7)
	move.l	d0,d7
	andi.l	#$ff,d7
	lea	$400,a1
	addq.l	#2,a1
	movem.l	(a1)+,d0-1
	andi.l	#$55555555,d0
	andi.l	#$55555555,d1
	add.l	d0,d0
	or.l	d1,d0
	rol.l	#8,d0
	cmp.b	d7,d0
	bne.s	lc4d836
	rol.l	#8,d0
	cmp.b	#1,d0
	bne.s	lc4d842
	lea	$4500,a0
	move.w	#$5e3,d7
lc4d814	movem.l	(a1)+,d0-1
	andi.l	#$55555555,d0
	andi.l	#$55555555,d1
	add.l	d0,d0
	or.l	d1,d0
	move.l	d0,(a0)+
	dbf	d7,lc4d814
	moveq	#1,d0
	movem.l	(a7)+,d1-2/d6-7/a1
	rts
	
lc4d836	move.l	#$fe,d0
	movem.l	(a7)+,d1-2/d6-7/a1
	rts
	
lc4d842	move.l	#$fc,d0
	movem.l	(a7)+,d1-2/d6-7/a1
	rts
	
lc4d84e	movem.l	d0/a0/a5,-(a7)
	lea	$dff000,a5
	move.w	#$5542,$7e(a5)
	move.w	#$8400,$9e(a5)
	move.w	#$4000,$24(a5)
	lea	$400,a0
	move.l	a0,$20(a5)
	move.l	#$4004,d0
	asr.w	#1,d0
	ori.w	#$8000,d0
	move.w	d0,$24(a5)
	move.w	d0,$24(a5)
	move.w	#2,$9c(a5)
lc4d88e	move.w	$1e(a5),d0
	btst	#1,d0
	beq.s	lc4d88e
	move.w	d0,$9c(a5)
	move.w	#$4000,$24(a5)
	move.w	#$400,$9e(a5)
	movem.l	(a7)+,d0/a0/a5
	rts
	
lc4d8ae	movem.l	d0/a0/a5,-(a7)
	lea	$dff000,a5
	move.w	#$4000,$24(a5)
	lea	$400,a0
	move.l	a0,$20(a5)
	move.l	#$4004,d0
	asr.w	#1,d0
	ori.w	#$c000,d0
	move.w	d0,$24(a5)
	move.w	d0,$24(a5)
	move.w	#2,$9c(a5)
lc4d8e2	move.w	$1e(a5),d0
	btst	#1,d0
	beq.s	lc4d8e2
	move.w	d0,$9c(a5)
	move.w	#$4000,$24(a5)
	movem.l	(a7)+,d0/a0/a5
	rts
	
lc4d8fc	movem.l	d0/a0,-(a7)
	lea	$400,a0
	move.w	#$1000,d0
lc4d90a	move.l	#$44444444,(a0)+
	dbf	d0,lc4d90a
	movem.l	(a7)+,d0/a0
	rts
	
lc4d91a	movem.l	d4-7/a5,-(a7)
	moveq	#0,d4
	movea.l	a0,a5
	move.l	d0,d5
	move.l	d1,d7
	subq.l	#1,d7
	bsr	lc4d68c
	cmp.l	#0,d0
	beq	lc4d9b2
lc4d936	bsr	lc4d84e
	move.b	$5d02,d0
	move.b	d0,d5
	bsr	lc4d7d4
	cmp.l	#1,d0
	beq	lc4d968
	cmp.l	#$fe,d0
	beq	lc4d9ba
	cmp.l	#$fc,d0
	beq	lc4d9ba
	bra	lc4d9b2
lc4d968	moveq	#0,d4
	subi.l	#$1790,d7
	bmi	lc4d996
	lea	$4500,a0
	move.w	#$bc7,d0
lc4d97e	move.w	(a0)+,(a5)+
	dbf	d0,lc4d97e
	move.b	$5d02,d0
	addi.b	#1,d0
	bsr	lc4d68c
	bra	lc4d936
lc4d996	addi.l	#$1790,d7
	move.l	d7,d6
	lea	$4500,a0
lc4d9a4	move.b	(a0)+,(a5)+
	dbf	d6,lc4d9a4
	moveq	#1,d0
	movem.l	(a7)+,d4-7/a5
	rts
	
lc4d9b2	moveq	#0,d0
	movem.l	(a7)+,d4-7/a5
	rts
	
lc4d9ba	cmp.l	#8,d4
	beq	lc4d9b2
	addq.l	#1,d4
	bsr	lc4d5e8
	move.w	#$1000,d0
lc4d9ce	nop
	dbf	d0,lc4d9ce
	move.l	d5,d0
	bsr	lc4d68c
	bra	lc4d936
	movem.l	d7/a1/a5,-(a7)
	movea.l	a0,a5
	move.l	d1,d7
	subq.l	#1,d7
	bsr	lc4d68c
	move.l	d7,d0
	moveq	#0,d1
lc4d9f0	addq.l	#1,d1
	subi.l	#$1790,d0
	bpl	lc4d9f0
	move.l	d1,d6
	subq.l	#1,d6
lc4da00	bsr	lc4d8fc
	lea	$4500,a1
	move.w	#$bc7,d0
lc4da0e	move.w	(a5)+,(a1)+
	dbf	d0,lc4da0e
	move.b	$5d02,d0
	bsr	lc4d704
	bsr	lc4d8ae
	move.b	$5d02,d0
	addi.b	#1,d0
	bsr	lc4d68c
	dbf	d6,lc4da00
	movem.l	(a7)+,d7/a1/a5
	rts