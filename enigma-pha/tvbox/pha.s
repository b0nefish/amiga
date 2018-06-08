
pha	lea	pha_vertex(pc),a0
	lea	pha_rotated(pc),a1
	lea	sincos16(pc),a2
	lea	90*2(a2),a3
	move.w	(a0)+,d7
	subq.w	#1,d7

.loop1	movem.w	(a0)+,d0-d2

	move.w	logo91_alpha(pc),d4
	add.w	d4,d4
	move.w	(a2,d4.w),d3	; d3 = sin(alpha)
	move.w	(a3,d4.w),d4	; d4 = cos(alpha)
	move.w	d3,d5
	move.w	d4,d6
	
	muls.w	d0,d4		; d4 = OPx * cos(alpha) * k
	muls.w	d1,d3		; d3 = OPy * sin(alpha) * k
	muls.w	d1,d6		; d6 = OPy * cos(alpha) * k
	muls.w	d0,d5		; d5 = OPx * sin(alpha) * k
	sub.l	d3,d4
	add.l	d5,d6
	add.l	d4,d4
	add.l	d6,d6
	swap	d4
	swap	d6
	move.w	d4,d0		; d0 = OPx'
	move.w	d6,d1		; d1 = OPy'

	exg	d0,d2
	neg.w	d2	
	movem.w	d0-d2,(a1)
	lea	6(a1),a1
	
	dbf	d7,.loop1	; next vertex

	;---- rotate logo arround tvbox axis

	lea	pha_rotated(pc),a0
	lea	pha_boxrotated(pc),a1
	move.w	pha_vertex(pc),d7
	jsr	rotate_box(pc)
	
	;---- draw logo
	
.wblt1	btst	#6,2(a6)
	bne.b	.wblt1

	move.w	#40,$60(a6)		; bltcmod
	move.w	#40,$66(a6)		; bltdmod
	move.l	#$ffff8000,$72(a6)	; bltbdat + bltadat
	move.l	#$ffffffff,$44(a6)	; bltafwm + bltalwm

	;----
	
	lea	pha_boxrotated(pc),a1
	lea	pha_vectors(pc),a2
	move.w	(a2)+,d7
	subq.w	#1,d7

.loop2	movem.w	(a2)+,d0/d2
	lsl.w	#3,d0
	lsl.w	#3,d2
	movem.w	(a1,d0.w),d0/d1
	movem.w	(a1,d2.w),d2/d3

	;---- 1 pixel linedraw	

	moveq	#0,d5
	cmp.w	d1,d3
	beq.w	.done
	bpl.b	.dy
	exg	d0,d2
	exg	d1,d3
.dy	sub.w	d1,d3
.dx	sub.w	d0,d2
	bge.w	.fix	
	neg.w	d2
	addq.b	#4,d5
.fix	move.w	d3,d4
	add.w	d4,d4
	cmp.w	d4,d2
	blt.b	.delta
	subq.w	#1,d3		; (dx > 2dy ? dy=dy-1 : dy=dy)
.delta	cmp.w	d2,d3		; d2 = pdelta
	bge.b	.ptr		; d3 = gdelta	
	exg	d2,d3
	addq.b	#2,d5
.ptr	move.l	triplebuffer(pc),a0
	lea	40*256*2(a0),a0
	move.w	d0,d4
	lsr.w	#3,d4
	lea	(a0,d4.w),a0
	mulu	#40,d1
	lea	(a0,d1.w),a0
	andi.w	#$f,d0
	add.w	d0,d0
	add.w	d2,d2		; d2 = 2pdelta
.wblt2	btst	#6,2(a6)
	bne.b	.wblt2
	move.w	d2,$62(a6)	; bltbmod
	sub.w	d3,d2		; 2pdelta - gdelta	
	bpl.b	.aptl
	addq.b	#8,d5
.aptl	move.w	d2,$52(a6)	; bltaptl
	sub.w	d3,d2		; 2pdelta - 2gdelta
	move.w	d2,$64(a6)			; bltamod
	move.w	.bltcon0(pc,d0.w),$40(a6)	; bltcon0
	move.w	.bltcon1(pc,d5.w),$42(a6)	; bltcon1
	move.l	a0,$48(a6)	; bltcpt
	move.l	a0,$54(a6)	; bltdpt
	lsl.w	#6,d3
	addq.w	#2,d3
	move.w	d3,$58(a6)	; bltsize
	
	bra.w	.done
	
	;----

LF	SET	($f0&$55)+($0f&$aa)	; A XOR C

.bltcon0	
	dc.w	$0b00+LF, $1b00+LF, $2b00+LF, $3b00+LF
	dc.w	$4b00+LF, $5b00+LF, $6b00+LF, $7b00+LF
	dc.w	$8b00+LF, $9b00+LF, $ab00+LF, $bb00+LF
	dc.w	$cb00+LF, $db00+LF, $eb00+LF, $fb00+LF

.bltcon1
	dc.w	(%000<<2)+%0000011	; #6
	dc.w	(%100<<2)+%0000011	; #7
	dc.w	(%010<<2)+%0000011	; #5
	dc.w	(%101<<2)+%0000011	; #4

	dc.w	(%000<<2)+%1000011	; #6
	dc.w	(%100<<2)+%1000011	; #7
	dc.w	(%010<<2)+%1000011	; #5
	dc.w	(%101<<2)+%1000011	; #4

	;----
	
.done	dbf	d7,.loop2	

	;---- blitter fill
	
	move.l	triplebuffer(pc),a0
	lea	(40*256*3)-10(a0),a0
	
.wblt3	btst	#6,2(a6)
	bne.b	.wblt3
	
	move.l	a0,$50(a6)
	move.l	a0,$54(a6)
	move.w	#40-(12*2),$64(a6)
	move.w	#40-(12*2),$66(a6)	
	move.l	#(((%1001<<8)+%11110000)<<16)+%10010,$40(a6)
	move.w	#(256<<6)+12,$58(a6)	
	
	;----
	
	rts

	;-------------
	;---- 3d datas
	;-------------

pha_vertex
	dc.w	23

	;---- P

	dc.w	$ffee, $0036, -boxsize
	dc.w	$ffd0, $0018, -boxsize
	dc.w	$ffd0, $000c, -boxsize
	dc.w	$ffd6, $0012, -boxsize
	dc.w	$ffdc, $0006, -boxsize
	dc.w	$ffe2, $0006, -boxsize
	dc.w	$ffee, $0012, -boxsize
	dc.w	$ffee, $001e, -boxsize
	dc.w	$ffe8, $001e, -boxsize
	
	;---- H
	
	dc.w	$ffe8, $fffa, -boxsize
	dc.w	$fff4, $0012, -boxsize
	dc.w	$000c, $001e, -boxsize
	dc.w	$0000, $000c, -boxsize
	dc.w	$0006, $0006, -boxsize
	dc.w	$0018, $0012, -boxsize
	dc.w	$000c, $fffa, -boxsize
	dc.w	$fff4, $ffee, -boxsize
	dc.w	$0000, $0000, -boxsize
	
	;---- A
	
	dc.w	$fffa, $0006, -boxsize
	dc.w	$0006, $ffdc, -boxsize
	dc.w	$001e, $000c, -boxsize
	dc.w	$0020, $fff4, -boxsize
	dc.w	$0036, $ffee, -boxsize

pha_vectors
	dc.w	23

	dc.w	0,1
	dc.w	1,2
	dc.w	2,3
	dc.w	3,4
	dc.w	4,5
	dc.w	5,6
	dc.w	6,7
	dc.w	7,8
	dc.w	8,0

	dc.w	9,10
	dc.w	10,11
	dc.w	11,12
	dc.w	12,13
	dc.w	13,14
	dc.w	14,15
	dc.w	15,16
	dc.w	16,17
	dc.w	17,18
	dc.w	18,9

	dc.w	19,20
	dc.w	20,21
	dc.w	21,22
	dc.w	22,19

pha_rotated
	ds.w	3*23
	dc.b	'sebo'

pha_boxrotated
	ds.w	4*23
	dc.b	'sebo'

