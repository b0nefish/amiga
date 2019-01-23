
	SECTION	knight,CODE_C

	include	/knight/startup.s

height	EQU	160
zobs	EQU	-256

mainloop
	
	;---- clear bitmap

	move.l	doublebuffer(pc),a0
	lea	10(a0),a0
	move.l	a0,$54(a6)
	move.l	#(%100000000)<<16,$40(a6)
	move.w	#40-20,$66(a6)	
	move.w	#((height*3)<<6)+10,$58(a6)

	;---- 3d rotations

rotate_knight	
	lea	knight_vertices(pc),a0
	lea	knight_rotated(pc),a1
	lea	sincos16(pc),a2
	lea	90*2(a2),a3
	move.w	(a0)+,d7
	subq.w	#1,d7

_sin	EQUR	a2
_cos	EQUR	a3

.loop	movem.w	(a0)+,d0-d2
	asr.w	#2,d0
	asr.w	#2,d1
	asr.w	#2,d2

.z_rotate
	move.w	alpha(pc),d4
	add.w	d4,d4
	move.w	(_sin,d4.w),d3	; d3 = sin(alpha)
	move.w	(_cos,d4.w),d4	; d4 = cos(alpha)
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

.x_rotate
	move.w	beta(pc),d4
	add.w	d4,d4
	move.w	(_sin,d4.w),d3	; d3 = sin(beta)
	move.w	(_cos,d4.w),d4	; d4 = cos(beta)
	move.w	d3,d5
	move.w	d4,d6
	
	muls.w	d1,d4		; d4 = OPy * cos(beta) * k
	muls.w	d2,d3		; d3 = OPz * sin(beta) * k
	muls.w	d2,d6		; d6 = OPz * cos(beta) * k
	muls.w	d1,d5		; d5 = OPy * sin(beta) * k
	add.l	d3,d4
	sub.l	d5,d6
	add.l	d4,d4
	add.l	d6,d6
	swap	d4
	swap	d6
	move.w	d4,d1		; d1 = OPy''
	move.w	d6,d2		; d2 = OPz''

.y_rotate
	move.w	theta(pc),d4
	add.w	d4,d4
	move.w	(_sin,d4.w),d3	; d3 = sin(theha)
	move.w	(_cos,d4.w),d4	; d4 = cos(theta)
	move.w	d3,d5
	move.w	d4,d6
	
	muls.w	d0,d4		; d4 = OPx * cos(theta) * k
	muls.w	d2,d3		; d3 = OPz * sin(theta) * k
	muls.w	d2,d6		; d6 = OPz * cos(theta) * k
	muls.w	d0,d5		; d5 = OPx * sin(theta) * k
	sub.l	d3,d4
	add.l	d5,d6
	add.l	d4,d4
	add.l	d6,d6
	swap	d4
	swap	d6
	move.w	d4,d0		; d0 = OPx'''
	move.w	d6,d2		; d2 = OPz'''

	;---- projection
	
	move.w	d2,4(a1)	;
	subi.w	#zobs,d2	;
	beq.b	.done		;
	moveq	#8+3,d3		; k = 8 (scaling value)
	asl.w	#3,d2		; 
	ext.l	d0		;
	ext.l	d1		;
	asl.l	d3,d0		;
	asl.l	d3,d1		;
	divs.w	d2,d0		; P'x = - k(Px * Oz) / k(Pz - Oz)  
	divs.w	d2,d1		; P'y = - k(Py * Oz) / k(Pz - Oz)
.done	movem.w	d0/d1,(a1)	; 

	lea	8(a1),a1	;
	dbf	d7,.loop	;
 
	;----

uu	btst.b	#6,2(a6)
	bne.b	uu

plt	lea	knight_rotated(pc),a0
	move.w	knight_vertices(pc),d7
	subq.w	#1,d7
.loop	movem.w	(a0),d0/d1
	;move.w	#0,d0
	;move.w	#0,d1
	jsr	plot(pc)
	lea	8(a0),a0
	dbf	d7,.loop

	;---- animate
	
animate	movem.w	alpha(pc),d0-d2
	move.w	#360,d7

	;addq.w	#1,d0
	;addq.w	#3,d1
	addq.w	#1,d2

.clip1	cmp.w	d7,d0
	blt.b	.clip2
	sub.w	d7,d0
.clip2	cmp.w	d7,d1
	blt.b	.clip3
	sub.w	d7,d1
.clip3	cmp.w	d7,d2
	blt.b	.done
	sub.w	d7,d2

.done	movem.w	d0-d2,alpha

	;---- screen swap
	
	lea	doublebuffer(pc),a0
	movem.l	(a0),d0-d1
	exg	d0,d1
	movem.l	d0-d1,(a0)
	
	lea	copperlist(pc),a0	
	move.l	#40*height,d2

	move.w	d1,bitplaneptr-copperlist+(8*0)+6(a0)
	swap	d1
	move.w	d1,bitplaneptr-copperlist+(8*0)+2(a0)
	swap	d1

	add.l	d2,d1
	move.w	d1,bitplaneptr-copperlist+(8*1)+6(a0)
	swap	d1
	move.w	d1,bitplaneptr-copperlist+(8*1)+2(a0)
	swap	d1

	add.l	d2,d1
	move.w	d1,bitplaneptr-copperlist+(8*2)+6(a0)
	swap	d1
	move.w	d1,bitplaneptr-copperlist+(8*2)+2(a0)
	swap	d1

	;add.l	d2,d1
	;move.w	d1,bitplaneptr-copperlist+(8*3)+6(a0)
	;swap	d1
	;move.w	d1,bitplaneptr-copperlist+(8*3)+2(a0)
	;swap	d1

	;add.l	d2,d1
	;move.w	d1,bitplaneptr-copperlist+(8*4)+6(a0)
	;swap	d1
	;move.w	d1,bitplaneptr-copperlist+(8*4)+2(a0)
	;swap	d1

	;---- vbsync

.vbsync	btst.b	#6,2(a6)
	bne.b	.vbsync
	move.l	$4(a6),d0
	andi.l	#$1ff00,d0
	cmpi.l	#$13700,d0
	bne.b	.vbsync

	;---- test lmb

	btst.b	#6,$bfe001
	bne.w	mainloop

	;----
	
leave	rts

	;---- 1 pixel linedraw
	
draw1px	moveq	#0,d5
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
.ptr	move.l	doublebuffer(pc),a0
	move.w	d0,d4
	lsr.w	#3,d4
	mulu	#40,d1
	add.w	d4,d1	
	lea	(a0,d1.w),a0
	andi.w	#$f,d0
	add.w	d0,d0
	add.w	d2,d2		; d2 = 2pdelta
.wblt	btst.b	#6,2(a6)
	bne.b	.wblt
	move.w	d2,$62(a6)
	sub.w	d3,d2		; d2 = 2pdelta - gdelta	
	bpl.b	.aptl
	addq.b	#8,d5
.aptl	move.w	d2,d1				
	sub.w	d3,d2		; d2 = 2pdelta - 2gdelta
	move.w	d2,$64(a6)		
	move.w	.bltcon0(pc,d0.w),d0
	move.w	.bltcon1(pc,d5.w),d5		
	lsl.w	#6,d3
	addq.w	#2,d3
	bra.b	.plane1
	
	;----

LF	SET	($f0&$55)+($0f&$aa)	; A XOR C

.bltcon0	
	dc.w	$0b00+LF,$1b00+LF,$2b00+LF,$3b00+LF
	dc.w	$4b00+LF,$5b00+LF,$6b00+LF,$7b00+LF
	dc.w	$8b00+LF,$9b00+LF,$ab00+LF,$bb00+LF
	dc.w	$cb00+LF,$db00+LF,$eb00+LF,$fb00+LF

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

.plane1	ror.b	#1,d6
	bcc.b	.plane2
	move.w	d1,$52(a6)	
	movem.w	d0/d5,$40(a6)
	move.l	a0,$48(a6)
	move.l	a0,$54(a6)
	move.w	d3,$58(a6)	
	
.plane2	lea	40*height(a0),a0
	ror.b	#1,d6
	bcc.b	.plane3
.wblt1	btst.b	#6,2(a6)
	bne.b	.wblt1
	move.w	d1,$52(a6)	
	movem.w	d0/d5,$40(a6)
	move.l	a0,$48(a6)
	move.l	a0,$54(a6)
	move.w	d3,$58(a6)	

.plane3	lea	40*height(a0),a0
	ror.b	#1,d6
	bcc.b	.plane4
.wblt2	btst.b	#6,2(a6)
	bne.b	.wblt2
	move.w	d1,$52(a6)	
	movem.w	d0/d5,$40(a6)
	move.l	a0,$48(a6)
	move.l	a0,$54(a6)
	move.w	d3,$58(a6)	

.plane4	lea	40*height(a0),a0
	ror.b	#1,d6
	bcc.b	.plane5
.wblt3	btst.b	#6,2(a6)
	bne.b	.wblt3
	move.w	d1,$52(a6)	
	movem.w	d0/d5,$40(a6)
	move.l	a0,$48(a6)
	move.l	a0,$54(a6)
	move.w	d3,$58(a6)	

.plane5	lea	40*height(a0),a0
	ror.b	#1,d6
	bcc.b	.done
.wblt4	btst.b	#6,2(a6)
	bne.b	.wblt4
	move.w	d1,$52(a6)	
	movem.w	d0/d5,$40(a6)
	move.l	a0,$48(a6)
	move.l	a0,$54(a6)
	move.w	d3,$58(a6)	

.done	rts

	;---- plot

plot	movem.l	d0-d2/a0,-(sp)
	move.l	doublebuffer(pc),a0
	addi.w	#320/2,d0
	addi.w	#height/2,d1
	move.b	d0,d2
	lsr.w	#3,d0
	mulu.w	#40,d1
	add.w	d0,d1
	not.b	d2
	bset.b	d2,(a0,d1.w)
	movem.l	(sp)+,d0-d2/a0
	rts
	
	;---- copperlist
	
copperlist
	dc.w	$8e,$2c81
	dc.w	$90,$2cc1
	dc.w	$92,$38
	dc.w	$94,$d0
	dc.w	$100,$0200
	dc.w	$102,0
bplcon2	dc.w	$104,0

colors	dc.w	$180,0
	dc.w	$182,$fff	 
	dc.w	$184,$000	
	dc.w	$186,$c03
	dc.w	$188,$000
	dc.w	$18a,$602	 
	dc.w	$18c,$000	
	dc.w	$18e,$401	 
	dc.w	$190,$000	
	dc.w	$192,$f30	 
	dc.w	$194,$c20	
	dc.w	$196,$810	

bitplaneptr
	dc.w	$e0,0
	dc.w	$e2,0
	dc.w	$e4,0
	dc.w	$e6,0
	dc.w	$e8,0
	dc.w	$ea,0
	dc.w	$ec,0
	dc.w	$ee,0
	dc.w	$f0,0
	dc.w	$f2,0

	dc.w	$4f01,$fffe
	dc.w	$180,$f
	dc.w	$5001,$fffe
	dc.w	$100,$3200
	dc.w	$180,0
	dc.w	$f001,$fffe
	dc.w	$100,$0200
	dc.w	$180,$f
	dc.w	$f101,$fffe
	dc.w	$180,0
	
	dc.l	-2

	;----

doublebuffer
	dc.l	bitplane1
	dc.l	bitplane2

	;----
	
alpha	dc.w	0	; rotate angles
beta	dc.w	90	; 
theta	dc.w	0	; 

	;---- 3d datas
	
knight_vertices
	incbin	/knight/knight
	
knight_rotated
	ds.w	52*4

	;---- maths tables
		
sincos16
	incbin	sincos16
	
	;---- bitplanes
	
bitplane1
	ds.w	20*height*3
	
bitplane2
	ds.w	20*height*3	
