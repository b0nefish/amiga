
	move.l	4.w,a6
	lea	gfxname(pc),a1
	moveq	#0,d0
	jsr	-408(a6)
	move.l	d0,a0
	move.l	38(a0),oldcopper

	jsr	-132(a6)
	
	lea	$dff000,a6
	move.w	$2(a6),d0
	ori.w	#$8000,d0
	move.w	d0,dma
	move.w	$1c(a6),d0
	ori.w	#$8000,d0
	move.w	d0,intena
	move.w	#$7fff,$96(a6)
	move.w	#$7fff,$9a(a6)	

	;lea	copperlist(pc),a0
	;move.l	triplebuffer+8(pc),a1
	;move.l	a1,d0
	;move.w	d0,bitplaneptr-copperlist+6(a0)
	;swap	d0
	;move.w	d0,bitplaneptr-copperlist+2(a0)
	
	;move.l	a0,$80(a6)
	;clr.w	$88(a6)
	;move.w	#$83c0,$96(a6)	

	lea	call(pc),a0
	jsr	(a0)
	
waitlmb
	btst	#6,$bfe001
	bne	waitlmb

	move.w	#$7fff,$96(a6)
	move.w	#$7fff,$9a(a6)
	move.l	oldcopper(pc),$80(a6)
	clr.w	$88(a6)
	move.w	dma(pc),$96(a6)
	move.w	intena(pc),$9a(a6)

	move.l	4.w,a6
	jsr	-138(a6)
	rts

gfxname
	dc.b	'graphics.library',0
	
	EVEN
	
dma
	ds.w	1
intena
	ds.w	1
oldcopper
	ds.l	1
call
