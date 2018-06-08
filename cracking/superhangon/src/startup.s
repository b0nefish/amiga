
	move.l	4.w,a6
	jsr	-132(a6)
	jsr	-120(a6)
	
	lea	$dff000,a6
	move.w	$2(a6),d0
	ori.w	#$8000,d0
	move.w	d0,dma
	move.w	$1c(a6),d0
	ori.w	#$8000,d0
	move.w	d0,intena
	move.w	#$7fff,$96(a6)
	move.w	#$7fff,$9a(a6)	

	lea	call(pc),a0
	jsr	(a0)
	
waitlmb	;btst.b	#6,$bfe001
	;bne.b	waitlmb

	move.w	#$7fff,$96(a6)
	move.w	#$7fff,$9a(a6)
	move.w	dma(pc),$96(a6)
	move.w	intena(pc),$9a(a6)

	move.l	4.w,a6
	jsr	-138(a6)
	jsr	-126(a6)
	rts
	
dma	ds.w	1
intena	ds.w	1

call
