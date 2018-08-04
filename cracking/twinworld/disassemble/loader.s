; $0000FE60

	;---- ENTRY POINTS

	bra	lc45d50 ; (0000FE60) LOAD_FILE()
	bra	lc45e40 ; (0000FE64) WRITE_DATA()
	bra	lc458ee	; (0000FE68) DRIVE_ON() 
	bra	lc45916 ; (0000FE6C) DRIVE_STOP()
	bra	lc4585c ; (0000FE70) BREACKPOINT
	bra	lc4586e ; (0000FE74) BREACKPOINT
	
	;----
	
lc4585c
	bsr	lc45888
	bsr	lc458ee
	bsr	lc458c0
	bsr	lc45a14
	rts
	
lc4586e	bsr	lc45a14
	bsr	lc45916
	rts
	
lc45878	ori.b	#$78,$bfd100
	nop
	nop
	nop
	rts
	
lc45888	bsr	lc45878
	cmpi.l	#3,d0
	bhi	lc458a8
	addq.l	#3,d0
	bclr	d0,$bfd100
	nop
	nop
	nop
	moveq	#1,d0
	rts
	
lc458a8	moveq	#0,d0
	rts
	
	btst	#3,$bfe001
	bne	lc458bc
	moveq	#1,d0
	rts
	
lc458bc	moveq	#0,d0
	rts
	
lc458c0	btst	#5,$bfe001
	bne	lc458c0
	rts
	
lc458ce	bclr	#2,$bfd100
	nop
	nop
	nop
	rts
	
lc458de	bset	#2,$bfd100
	nop
	nop
	nop
	rts
	
lc458ee	movem.l	d0/a5,-(a7)
	lea	$bfd000,a5
	move.b	$100(a5),d0
	bsr	lc45878
	bclr	#7,$100(a5)
	nop
	nop
	nop
	move.b	d0,$100(a5)
	movem.l	(a7)+,d0/a5
	rts
	
lc45916	movem.l	d0/a5,-(a7)
	lea	$bfd000,a5
	move.b	$100(a5),d0
	bsr	lc45878
	bset	#7,$100(a5)
	nop
	nop
	nop
	move.b	d0,$100(a5)
	movem.l	(a7)+,d0/a5
	rts
	
lc4593e	movem.l	d0,-(a7)
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
	move.l	#$a00,d0
lc45972	nop
	dbf	d0,lc45972
	movem.l	(a7)+,d0
	rts
	
lc4597e	movem.l	d0,-(a7)
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
	move.l	#$a00,d0
lc459b2	nop
	dbf	d0,lc459b2
	movem.l	(a7)+,d0
	rts
	
lc459be	andi.l	#$ff,d0
	subq.l	#1,d0
lc459c6	bsr	lc4597e
	dbf	d0,lc459c6
	rts
	
lc459d0	andi.l	#$ff,d0
	subq.l	#1,d0
lc459d8	bsr	lc4593e
	dbf	d0,lc459d8
	rts
	
lc459e2	movem.l	d1,-(a7)
	moveq	#$64,d1
lc459e8	btst	#4,$bfe001
	beq	lc45a04
	bsr	lc4593e
	dbf	d1,lc459e8
	moveq	#0,d0
	movem.l	(a7)+,d1
	rts
	
lc45a04	move.b	#0,$5d00
	moveq	#1,d0
	movem.l	(a7)+,d1
	rts
	
lc45a14	bsr	lc459e2
	cmp.l	#0,d0
	beq	lc45a32
	bsr	lc458ce
	move.b	#0,$5d02
	moveq	#1,d0
	rts
	
lc45a32	moveq	#0,d0
	rts
	
lc45a36	movem.l	d1-2,-(a7)
	cmp.b	$5d00,d0
	beq	lc45a6e
	cmp.b	#$4f,d0
	bhi	lc45a66
	tst.b	d0
	beq	lc45a76
	cmp.b	$5d00,d0
	bmi	lc45a88
	cmp.b	$5d00,d0
	bpl	lc45aa2
lc45a66	moveq	#0,d0
	movem.l	(a7)+,d1-2
	rts
	
lc45a6e	moveq	#1,d0
	movem.l	(a7)+,d1-2
	rts
	
lc45a76	bsr	lc459e2
	cmp.l	#1,d0
	beq	lc45a6e
	bra	lc45a66
lc45a88	move.b	d0,d2
	move.b	$5d00,d1
	sub.b	d0,d1
	move.b	d1,d0
	bsr	lc459d0
	move.b	d2,$5d00
	bra	lc45a6e
lc45aa2	move.b	d0,d2
	sub.b	$5d00,d0
	bsr	lc459be
	move.b	d2,$5d00
	bra	lc45a6e
lc45ab8	movem.l	d1-2,-(a7)
	cmp.b	#$9f,d0
	bhi	lc45af4
	cmp.b	#$4f,d0
	bhi	lc45b0e
	tst.b	d0
	beq	lc45afc
	move.b	d0,d2
	bsr	lc458ce
	bsr	lc45a36
	cmp.l	#0,d0
	beq	lc45af4
	move.b	d2,$5d02
lc45aec	moveq	#1,d0
	movem.l	(a7)+,d1-2
	rts
	
lc45af4	moveq	#0,d0
	movem.l	(a7)+,d1-2
	rts
	
lc45afc	bsr	lc45a14
	cmp.l	#1,d0
	beq	lc45aec
	bra	lc45af4
lc45b0e	move.b	d0,d2
	bsr	lc458de
	subi.b	#$50,d0
	bsr	lc45a36
	cmp.l	#0,d0
	beq	lc45af4
	move.b	d2,$5d02
	bra	lc45aec
lc45b30	movem.l	d1-2/d7/a0-2,-(a7)
	move.l	d0,d7
	andi.l	#$ff,d7
	bsr	lc45d30
	lea	$400,a1
	lea	$10b0(a1),a1
	move.w	#$5542,(a1)+
	move.w	#$aaaa,d0
	btst	#0,-1(a1)
	beq	lc45b60
	move.w	#$2aaa,d0
lc45b60	move.w	d0,(a1)+
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
lc45ba8	move.l	(a1)+,d0
	move.l	d0,d1
	andi.l	#$55555555,d1
	lsr.l	#1,d0
	andi.l	#$55555555,d0
	move.l	d0,(a2)+
	move.l	d1,(a2)+
	dbf	d7,lc45ba8
	lea	$400,a0
	lea	$10b0(a0),a0
	lea	4(a0),a0
	move.l	#$1793,d7
lc45bd6	move.w	(a0),d0
	move.w	d0,d2
	eori.w	#$5555,d0
	move.w	d0,d1
	lsl.w	#1,d0
	lsr.w	#1,d1
	bset	#$f,d1
	and.w	d1,d0
	or.w	d2,d0
	btst	#0,-1(a0)
	beq	lc45bfa
	bclr	#$f,d0
lc45bfa	move.w	d0,(a0)+
	dbf	d7,lc45bd6
	movem.l	(a7)+,d1-2/d7/a0-2
	rts
	
lc45c06	movem.l	d1-2/d6-7/a1,-(a7)
	move.l	d0,d7
	andi.l	#$ff,d7
	lea	$400,a1
	addq.l	#2,a1
	move.l	(a1)+,d0
	move.l	(a1)+,d1
	andi.l	#$55555555,d0
	andi.l	#$55555555,d1
	lsl.l	#1,d0
	or.l	d1,d0
	rol.l	#8,d0
	cmp.b	d7,d0
	bne.s	lc45c6a
	rol.l	#8,d0
	cmp.b	#1,d0
	bne.s	lc45c76
	lea	$4500,a0
	move.l	#$5e3,d7
lc45c48	move.l	(a1)+,d0
	move.l	(a1)+,d1
	andi.l	#$55555555,d0
	andi.l	#$55555555,d1
	lsl.l	#1,d0
	or.l	d1,d0
	move.l	d0,(a0)+
	dbf	d7,lc45c48
	moveq	#1,d0
	movem.l	(a7)+,d1-2/d6-7/a1
	rts
	
lc45c6a	move.l	#$fe,d0
	movem.l	(a7)+,d1-2/d6-7/a1
	rts
	
lc45c76	move.l	#$fc,d0
	movem.l	(a7)+,d1-2/d6-7/a1
	rts
	
lc45c82	movem.l	d0/a0/a5,-(a7)
	lea	$dff000,a5
	move.w	#$5542,$7e(a5)
	move.w	#$8400,$9e(a5)
	move.w	#$4000,$24(a5)
	lea	$400,a0
	move.l	a0,$20(a5)
	move.l	#$4004,d0	; raw buffer = $4004 bytes
	asr.w	#1,d0
	ori.w	#$8000,d0
	move.w	d0,$24(a5)
	move.w	d0,$24(a5)
	move.w	#2,$9c(a5)
lc45cc2	move.w	$1e(a5),d0
	btst	#1,d0
	beq.s	lc45cc2
	move.w	d0,$9c(a5)
	move.w	#$4000,$24(a5)
	move.w	#$400,$9e(a5)
	movem.l	(a7)+,d0/a0/a5
	rts
	
lc45ce2	movem.l	d0/a0/a5,-(a7)
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
lc45d16	move.w	$1e(a5),d0
	btst	#1,d0
	beq.s	lc45d16
	move.w	d0,$9c(a5)
	move.w	#$4000,$24(a5)
	movem.l	(a7)+,d0/a0/a5
	rts
	
lc45d30	movem.l	d0/a0,-(a7)
	lea	$400,a0
	move.l	#$1000,d0
lc45d40	move.l	#$44444444,(a0)+
	dbf	d0,lc45d40
	movem.l	(a7)+,d0/a0
	rts

; $0001036C (main)
	
lc45d50	movem.l	d4-7/a5,-(a7)
	andi.l	#$ff,d0
	tst.l	d2
	bne	lc45e2e
lc45d60	move.l	d0,d5
	bsr	lc45ab8
	cmp.l	#0,d0
	beq	lc45e00
	moveq	#0,d4
	movea.l	a0,a5
	move.l	d1,d7
	subq.l	#1,d7
	add.l	d2,d7
lc45d7a	bsr	lc45c82
	move.b	$5d02,d0
	move.b	d0,d5
	bsr	lc45c06
	cmp.l	#1,d0
	beq	lc45dac
	cmp.l	#$fe,d0
	beq	lc45e08
	cmp.l	#$fc,d0
	beq	lc45e08
	bra	lc45e00
lc45dac	moveq	#0,d4
	subi.l	#$1790,d7
	bmi	lc45de2
	lea	$4500,a0
	adda.l	d2,a0
	move.l	#$178f,d0
	sub.l	d2,d0
lc45dc8	move.b	(a0)+,(a5)+
	dbf	d0,lc45dc8
	moveq	#0,d2
	move.b	$5d02,d0
	addi.b	#1,d0
	bsr	lc45ab8
	bra	lc45d7a
lc45de2	addi.l	#$1790,d7
	lea	$4500,a0
	adda.l	d2,a0
	sub.l	d2,d7
lc45df2	move.b	(a0)+,(a5)+
	dbf	d7,lc45df2
	moveq	#1,d0
	movem.l	(a7)+,d4-7/a5
	rts ; ($0001041A)
	
lc45e00	moveq	#0,d0
	movem.l	(a7)+,d4-7/a5
	rts
	
lc45e08	cmp.l	#5,d4
	beq	lc45e00
	addq.l	#1,d4
	bsr	lc45a14
	move.l	#$1000,d0
lc45e1e	nop
	dbf	d0,lc45e1e
	move.l	d5,d0
	bsr	lc45ab8
	bra	lc45d7a
lc45e2e	divu	#$1790,d2
	add.w	d2,d0
	swap	d2
	andi.l	#$ffff,d2
	bra	lc45d60
	
lc45e40	movem.l	d7/a1/a5,-(a7)
	movea.l	a0,a5
	move.l	d1,d7
	subq.l	#1,d7
	bsr	lc45ab8
	move.l	d7,d0
	moveq	#0,d1
lc45e52	addq.l	#1,d1
	subi.l	#$1790,d0
	bpl	lc45e52
	move.l	d1,d6
	subq.l	#1,d6
lc45e62	bsr	lc45d30
	lea	$4500,a1
	move.l	#$bc7,d0
lc45e72	move.w	(a5)+,(a1)+
	dbf	d0,lc45e72
	move.b	$5d02,d0
	bsr	lc45b30
	bsr	lc45ce2
	move.b	$5d02,d0
	addi.b	#1,d0
	bsr	lc45ab8
	dbf	d6,lc45e62
	movem.l	(a7)+,d7/a1/a5
	rts