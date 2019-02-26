
	SECTION	roundvec,CODE_C

	include	/roundvec/startup.s

mainloop

	lea	copperlist(pc),a0
	lea	bitmap,a1
	move.l	a1,d0
	move.w	d0,bitplaneptr-copperlist+6(a0)
	swap	d0
	move.w	d0,bitplaneptr-copperlist+2(a0)
	swap	d0
	addi.l	#40,d0
	move.w	d0,bitplaneptr-copperlist+6+8(a0)
	swap	d0
	move.w	d0,bitplaneptr-copperlist+2+8(a0)

	;---- draw

frame	EQU	50

	lea	bitmap,a0
	lea	table(pc),a1	
	lea	ptrs(pc),a2
	lea	round(pc),a3
	move.l	frame*4(a2),d0
	lea	(a3,d0.l),a4
	moveq	#0,d6
	move.w	frame*2(a1),d7

.loop	move.b	(a4)+,d6
	lea	(a0,d6.w),a0
	move.b	(a4)+,(a0)
	dbf	d7,.loop
	
	;---- fill

	lea	bitmap,a0
	lea	(40*96*2)-2(a0),a0
.wblt	btst.b	#6,2(a6)
	bne.b	.wblt
	move.l	a0,$50(a6)
	move.l	a0,$54(a6)
	move.w	#0,$64(a6)
	move.w	#0,$66(a6)	
	move.l	#(((%1001<<8)+%11110000)<<16)+%01010,$40(a6)
	move.w	#((96*2)<<6)+20,$58(a6)	
.done

	;----

lmb	btst.b	#6,$bfe001
	bne.b	lmb

	rts

	;---- copperlist
	
copperlist
	dc.w	$8e,$2c81
	dc.w	$90,$2cc1
	dc.w	$92,$38
	dc.w	$94,$d0
	dc.w	$100,$2200
	dc.w	$102,0
	dc.w	$104,0
	dc.w	$108,40
	dc.w	$10a,40
	dc.w	$180,0
	dc.w	$182,$fab
	dc.w	$184,$f6a
	dc.w	$186,$534

bitplaneptr
	dc.w	$e0,0
	dc.w	$e2,0
	dc.w	$e4,0
	dc.w	$e6,0

	dc.w	(($2c+96-1)<<8)!1,$fffe
	dc.w	$108,-40-80
	dc.w	$10a,-40-80

	dc.w	(($2c+96+96-1)<<8)!1,$fffe
	dc.w	$100,$0200	
	dc.l	-2
	
	; ---- tables

table	incbin	/roundvec/table
ptrs	incbin	/roundvec/pointers
round	incbin	/roundvec/round.dat

	;---- bitmaps
	
bitmap	ds.w	20*256*2
	
