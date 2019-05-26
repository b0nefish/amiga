test	lea	shogfx1+8(pc),a0
	lea	shogfx2+8(pc),a1

	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	move.w	#42-1,d7	; 42 files

.loop	move.l	(a0),d0
	move.l	(a1),d1
	eor.l	d1,d0
	bne.b	.quit
	move.w	6(a0),d4
	add.l	d4,d2
	add.l	8(a1),d3
	lea	8(a0),a0
	lea	12(a1),a1
	dbf	d7,.loop

.quit	rts

shogfx1	incbin	/bin/shografx
shogfx2	include	/src/shografx.s
