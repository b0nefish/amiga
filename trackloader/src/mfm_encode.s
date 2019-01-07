
enc	move.l	#$55555555,d6

	lea	data(pc),a0	;
	lea	mfm(pc),a1	;
	moveq	#4-1,d7
.loop1	move.l	(a0)+,d0	; d0 = even bits
	move.l	d0,d1		; d1 = odd bits
	lsr.l	#1,d1
	and.l	d6,d0
	and.l	d6,d1
	movem.l	d0/d1,(a1)
	lea	8(a1),a1	
	dbf	d7,.loop1

	;----

	lea	mfm(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#(8*2)-1,d7
.loop2	move.w	(a0),d0
	move.l	d0,d1
	move.l	d0,d2
	lsr.l	#2,d1
	or.w	d1,d2
	eor.w	d6,d2
	add.w	d2,d2
	or.w	d2,d0
	move.w	d0,(a0)+
	andi.w	#1,d0
	swap	d0
	dbf	d7,.loop2
	rts


data	dc.b	'mfm encode test1'

mfm	ds.l	4*2	
