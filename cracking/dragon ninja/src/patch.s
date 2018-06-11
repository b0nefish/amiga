
	lea	data(pc),a0
	move.l	a0,a1
	jsr	bytekiller(pc)

	lea	patch(pc),a0
	lea	data+4790(pc),a1
	move.w	#endpatch-patch-1,d7
copy	move.b	(a0)+,(a1)+
	dbf	d7,copy

	move.w	#1296-1,d7
clr	clr.b	(a1)+
	dbf	d7,clr

	rts

	;----

patch	move.l	#$a8d398fb,d0
	move.l	d0,$24.w
	rts
endpatch

	;----
	
; bytekiller 1.3 decrunch routine
; a0 = source packed data
; a1 = target buffer

bytekiller
	move.l	-(a0),d1
	move.l	-(a0),d5
	lea	(a1,d1.l),a2
	move.l	-(a0),d0
	eor.l	d0,d5
	
lc45a0a	lsr.l	#1,d0
	bne.b	lc45a12
	bsr.w	lc45ab2

lc45a12	bcs.b	lc45a50
	moveq	#8,d1
	moveq	#1,d3
	lsr.l	#1,d0
	bne.b	lc45a20
	bsr.b	lc45ab2

lc45a20	bcs.b	lc45a7c
	moveq	#3,d1
	clr.w	d4

lc45a26	bsr.w	lc45abe
	move.w	d2,d3
	add.w	d4,d3

lc45a2e	moveq	#7,d1

lc45a30	lsr.l	#1,d0
	bne.b	lc45a38
	bsr.b	lc45ab2

lc45a38	roxl.l	#1,d2
	dbf	d1,lc45a30
	move.b	d2,-(a2)
	dbf	d3,lc45a2e
	bra.b	lc45a8a

lc45a48	moveq	#8,d1
	moveq	#8,d4
	bra.b	lc45a26

lc45a50	moveq	#2,d1
	bsr.b	lc45abe
	cmpi.b	#2,d2
	blt.b	lc45a72
	cmpi.b	#3,d2
	beq.b	lc45a48
	moveq	#8,d1
	bsr.b	lc45abe
	move.w	d2,d3
	move.w	#$c,d1
	bra.b	lc45a7c

lc45a72	move.w	#9,d1
	add.w	d2,d1
	addq.w	#2,d2
	move.w	d2,d3

lc45a7c	bsr.b	lc45abe

lc45a80	subq.w	#1,a2
	move.b	0(a2,d2.w),(a2)
	dbf	d3,lc45a80

lc45a8a	move.l	a0,$dff180
	cmpa.l	a2,a1
	blt.b	lc45a0a
	tst.l	d5
	bne.b	lc45aa0
	rts
	
	;----
	
lc45aa0	move.w	#$ffff,d0
lc45aa4	move.w	d0,$dff180
	dbf	d0,lc45aa4
	moveq	#-1,d0
	rts
	
	;----
	
lc45ab2	move.l	-(a0),d0
	eor.l	d0,d5
	move.b	#%10000,ccr
	roxr.l	#1,d0
	rts
	
	;----
	
lc45abe	subq.w	#1,d1
	clr.w	d2
lc45ac2	lsr.l	#1,d0
	bne.b	lc45ad0
	move.l	-(a0),d0
	eor.l	d0,d5
	move.b	#%10000,ccr
	roxr.l	#1,d0
lc45ad0	roxl.l	#1,d2
	dbf	d1,lc45ac2
	rts

	;----
	
	incbin	'hd1:cracking/dragon ninja/bin/copylock1'
data	ds.b	30896
end


