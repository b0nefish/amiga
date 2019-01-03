
	SECTION	spacecut,CODE_C

	include	/spacecut/startup.s

zobs	EQU	-256

mainloop

	;---- clear bitmap

	move.l	doublebuffer(pc),$54(a6)
	move.l	#(%100000000)<<16,$40(a6)
	move.l	#0,$64(a6)	
	move.w	#((256*3)<<6)+20,$58(a6)

wrblt	btst	#6,2(a6)
	bne.b	wrblt

	move.l	doublebuffer(pc),a0
	lea	3*40*256(a0),a0
	move.l	a0,$54(a6)
	move.l	#(%100000000)<<16,$40(a6)
	move.l	#0,$64(a6)	
	move.w	#((256*1)<<6)+20,$58(a6)
	
	;---- cube 3d rotations
	
	lea	cube_vertex(pc),a0
	lea	cube_rotated(pc),a1
	lea	sincos16(pc),a2
	lea	90*2(a2),a3
	move.w	(a0)+,d7
	subq.w	#1,d7

_sin	EQUR	a2
_cos	EQUR	a3

rotate_cube
	movem.w	(a0)+,d0-d2

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

	;---- screening
	
	move.w	d2,d3
	subi.w	#zobs,d3	; PBz = Bz - Oz + Pz
	beq.b	.done
	ext.l	d0
	ext.l	d1
	asl.l	#8,d0
	asl.l	#8,d1
	divs.w	d3,d0		; PBx * (Oz - Pz) / PBz
	divs.w	d3,d1		; PBy * (Oz - Pz) / PBz
.done	movem.w	d0-d2,(a1)	; push rotated + projected point
	lea	8(a1),a1	
	dbf	d7,rotate_cube
 
	;---- plane 3d rotations
	
	lea	plane_vertex(pc),a0
	lea	plane_rotated(pc),a1
	move.w	(a0)+,d7
	subq.w	#1,d7

rotate_plane
	movem.w	(a0)+,d0-d2

.y_rotate
	move.w	theta(pc),d4
	;move.w	#91,d4
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

	;---- screening
	
	move.w	d2,d3
	subi.w	#zobs,d3	; PBz = Bz - Oz + Pz
	beq.b	.done
	ext.l	d0
	ext.l	d1
	asl.l	#8,d0
	asl.l	#8,d1
	divs.w	d3,d0		; PBx * (Oz - Pz) / PBz
	divs.w	d3,d1		; PBy * (Oz - Pz) / PBz
.done	movem.w	d0-d2,(a1)	; push rotated + projected point
	lea	8(a1),a1
	dbf	d7,rotate_plane
	
	;----
	;----
	
	lea	cube_rotated(pc),a0
	lea	cube_vectors+2(pc),a1
	lea	cube_faces(pc),a2
	move.w	(a2)+,d7
	subq.w	#1,d7		; d7 = face count

.loop	move.l	(a2)+,d6
	swap	d6		; d6 = [colour].w [linecount].w
	subq.w	#1,d6
		
	;---- hidden polygon
	
	move.w	0(a2),d5
	bpl.b	.a			
	neg.w	d5
.a	subq.w	#1,d5
	lsl.w	#3,d5				
	movem.w	(a1,d5.w),d4/d5
	lsl.w	#3,d4
	lsl.w	#3,d5
	tst.w	0(a2)
	bpl.b	.b
	exg	d4,d5	
.b	movem.w	(a0,d4.w),d0/d1
	sub.w	0(a0,d5.w),d0	; x1 - x2
	sub.w	2(a0,d5.w),d1	; y1 - y2

	move.w	2(a2),d5			
	bpl.b	.c
	neg.w	d5
.c	subq.w	#1,d5
	lsl.w	#3,d5				
	movem.w	(a1,d5.w),d4/d5
	lsl.w	#3,d4
	lsl.w	#3,d5
	tst.w	2(a2)
	bpl.b	.d
	exg	d4,d5
.d	movem.w	(a0,d4.w),d2/d3
	sub.w	0(a0,d5.w),d2	; x4 - x3
	sub.w	2(a0,d5.w),d3	; y4 - y3

	muls.w	d3,d0
	muls.w	d2,d1
	sub.l	d1,d0		; d0 = AB /\ AC
	
	;---- edge xoring
	
.xor	swap	d6
	move.w	(a2)+,d1			
	bpl.b	.e
	neg.w	d1
.e	tst.l	d0
	bmi.b	.next
	subq.w	#1,d1
	lsl.w	#3,d1
	eor.w	d6,4(a1,d1.w)	; update vector colour index
.next	swap	d6	
	dbf	d6,.xor
	dbf	d7,.loop
 
	;---- draw cube

draw_cube
	lea	cube_vectors(pc),a1
	lea	cube_rotated(pc),a2
	move.w	(a1)+,d7
	subq.w	#1,d7

.wblt	btst.b	#6,2(a6)
	bne.b	.wblt

	move.w	#40,$60(a6)		; bltcmod
	move.w	#40,$66(a6)		; bltdmod
	move.l	#$ffff8000,$72(a6)	; bltbdat + bltadat
	move.l	#$ffffffff,$44(a6)	; bltafwm + bltalwm

.loop	movem.w	(a1)+,d4-d5
	move.w	(a1)+,d6
	beq.b	.next
	lsl.w	#3,d4
	lsl.w	#3,d5
	movem.w	(a2,d4.w),d0/d1		; PA
	movem.w	(a2,d5.w),d2/d3		; PB
	addi.w	#320/2,d0		; Ax
	addi.w	#256/2,d1		; Ay
	addi.w	#320/2,d2		; Bx
	addi.w	#256/2,d3		; By
	clr.w	-2(a1)			; clear colour index
	jsr	draw1px(pc)
.next	lea	2(a1),a1
	dbf	d7,.loop
 
	;---- draw plane

draw_plane
	lea	plane_vectors(pc),a1
	lea	plane_rotated(pc),a2
	move.w	(a1)+,d7
	subq.w	#1,d7

.loop	movem.w	(a1)+,d4-d5
	move.w	(a1)+,d6
	beq.b	.next
	lsl.w	#3,d4
	lsl.w	#3,d5
	movem.w	(a2,d4.w),d0/d1
	movem.w	(a2,d5.w),d2/d3
	addi.w	#320/2,d0
	addi.w	#256/2,d1
	addi.w	#320/2,d2
	addi.w	#256/2,d3
	jsr	draw1px(pc)
.next	lea	2(a1),a1
	dbf	d7,.loop
 
	;---- animate
	
moveangles
	movem.w	alpha(pc),d0-d2
	addq.w	#1,d0
	addq.w	#1,d1
	addq.w	#1,d2
clipalpha
	cmpi.w	#360,d0
	blt.b	clipbeta
	subi.w	#360,d0
clipbeta
	cmpi.w	#360,d1
	blt.b	cliptheta
	subi.w	#360,d1
cliptheta
	cmpi.w	#360,d2
	blt.b	clipdone
	subi.w	#360,d2
clipdone
	movem.w	d0-d2,alpha

	;---- blitter fill

fill	move.l	doublebuffer(pc),a0
	lea	(40*256*3)-2(a0),a0
	
.wblt	btst.b	#6,2(a6)
	bne.b	.wblt
	
	move.l	a0,$50(a6)
	move.l	a0,$54(a6)
	move.w	#0,$64(a6)
	move.w	#0,$66(a6)	
	move.l	#(((%1001<<8)+%11110000)<<16)+%10010,$40(a6)
	move.w	#((256*3)<<6)+20,$58(a6)	

	;---- cut plane parameters
	;
	; plane parametric equation :
	; Ax + By + Cz + d = 0 

plane	lea	plane_params(pc),a0
	lea	plane_rotated(pc),a1
	
	movem.w	8(a1),d0-d2	
	sub.w	0(a1),d0	; x1
	sub.w	2(a1),d1	; y1
	sub.w	4(a1),d2	; z1
	
	movem.w	8(a1),d3-d5
	sub.w	16(a1),d3	; x2
	sub.w	18(a1),d4	; y2
	sub.w	20(a1),d5	; z2
	
	move.w	d1,d6		;
	move.w	d4,d7		;
	muls.w	d5,d6		;
	muls.w	d2,d7		;
	sub.l	d7,d6		; d6 = A = y1z2 - y2z1 	

	muls.w	d3,d2		;
	muls.w	d0,d5		;
	sub.l	d5,d2		; d2 = B = z1x2 - z2x1 	

	muls.w	d4,d0		;
	muls.w	d1,d3		;
	sub.l	d3,d0		; d0 = C = x1y2 - x2y1 	

	asl.l	#8,d0		;
	asl.l	#8,d2		;
	asl.l	#8,d6		;
	add.l	d0,d0		;
	add.l	d2,d2		;
	add.l	d6,d6		;
	swap	d0		;
	swap	d2		;
	swap	d6		;
	move.w	d6,0(a0)	; A
	move.w	d2,2(a0)	; B
	move.w	d0,4(a0)	; C
	
	muls.w	0(a1),d6	; Ax
	muls.w	2(a1),d2	; By
	muls.w	4(a1),d0	; Cz
	add.l	d6,d2		;
	add.l	d2,d0		;
	neg.l	d0		;
	move.l	d0,6(a0)	; d = -(Ax + By + Cz)
 
	;----

	move.w	#zobs,d0	;
	muls.w	4(a0),d0	; d0 = CZo
	add.l	6(a0),d0	; d0 = CZo + d
	asl.l	#8,d0		;
	add.l	d0,d0		;
	swap	d0		;

	;---- ray/plane intersect

ray_plane_intersect
	lea	cube_rotated(pc),a1
	move.w	cube_vertex(pc),d7
	subq.w	#1,d7		; 

.loop	movem.w	(a1),d1-d3	;
	subi.w	#zobs,d3	;
	muls.w	0(a0),d1	; 
	muls.w	2(a0),d2	; 
	muls.w	4(a0),d3	; 
	add.l	d3,d2		;
	add.l	d2,d1		;
	asl.l	#8,d1		;
	add.l	d1,d1		;
	swap	d1		; 
	move.w	4(a1),d2	; 
	subi.w	#zobs,d2	; 
	muls.w	d0,d2		; 
	tst.w	d1		; 
	beq.b	.zero		; 
	divs.w	d1,d2		;
	ext.l	d2		;
.zero	move.l	#zobs,d1	;
	sub.l	d2,d1		;
	bclr.b	#0,6(a1)	; clear z flag
	cmpi.l	#zobs,d1	; ray intersect plane behind observer ?
	blt.b	.front		; yes => point is front of the plane	
	move.w	4(a1),d2	; no  => ray intersect plane front of obs.
	ext.l	d2		;
	cmp.l	d2,d1		; compare Zi and Zp 
	blt.b	.next		; 
.front	bset.b	#0,6(a1)	; 
.next	lea	8(a1),a1	; 
	dbf	d7,.loop	;

	;---- vector/plane intersect

vector_plane_intersect
	lea	cube_rotated(pc),a1
	lea	cube_vectors(pc),a2
	lea	cube_cutpoint(pc),a3
	move.w	(a2)+,d7
	subq.w	#1,d7		 

.loop	movem.w	(a2),d1/d4	;
	lsl.w	#3,d1		;
	lsl.w	#3,d4		;
	lea	(a1,d1.w),a4	; P1
	lea	(a1,d4.w),a5	; P2

	bclr.b	#0,6(a2)	; clear vector cut flag
	move.b	6(a4),d0	;
	move.b	6(a5),d1	;
	eor.b	d1,d0		;
	andi.b	#1,d0		; the plane cut vector ?
	beq.w	.next		; no  => go next vector
	bset.b	#0,6(a2)	; yes => calc intersect point

	movem.w	(a4),d0-d2	; P1(X,Y,Z)
	muls.w	0(a0),d0	;
	muls.w	2(a0),d1	; 
	muls.w	4(a0),d2	;
	add.l	d2,d1		;
	add.l	d1,d0		;
	add.l	6(a0),d0	;
	asl.l	#8,d0		;
	add.l	d0,d0		;
	swap	d0		;

	movem.w	(a4),d1-d3	; P1(X,Y,Z)
	movem.w	(a5),d4-d6	; P2(X,Y,Z)
	sub.w	d1,d4		; PX2 - PX1
	sub.w	d2,d5		; PY2 - PY1
	sub.w	d3,d6		; PZ2 - PZ1
	move.w	d4,d1		;
	move.w	d5,d2		;
	move.w	d6,d3		;
	muls.w	0(a0),d1	; 
	muls.w	2(a0),d2	; 
	muls.w	4(a0),d3	; 
	add.l	d3,d2		;
	add.l	d2,d1		;
	asl.l	#8,d1		;
	add.l	d1,d1		;
	swap	d1		;

	muls.w	d0,d4		;
	muls.w	d0,d5		;
	muls.w	d0,d6		; 
	tst.w	d1		; 
	beq.b	.zero		; 
	divs.w	d1,d4		;
	divs.w	d1,d5		;
	divs.w	d1,d6		;
	ext.l	d4		;
	ext.l	d5		;
	ext.l	d6		;
.zero	movem.w	(a4),d1-d3	;
	sub.l	d4,d1		; d1 = Xi
	sub.l	d5,d2		; d2 = Yi
	sub.l	d6,d3		; d3 = Zi

	movem.w	d1-d3,(a3)	; save cut point coordinates

	move.w	d1,d0
	move.w	d2,d1
	jsr	plot(pc)

.next	lea	8(a2),a2	;
	lea	8(a3),a3	;
	dbf	d7,.loop	;

	;----

	lea	cube_rotated,a1
	moveq	#8-1,d7	
.plt	movem.w	(a1),d0/d1
	btst.b	#0,6(a1)
	beq.b	.nx
	jsr	plot(pc)
.nx	lea	8(a1),a1
	dbf	d7,.plt

	;---- screen swap
	
	lea	doublebuffer(pc),a0
	movem.l	(a0),d0-d1
	exg	d0,d1
	movem.l	d0-d1,(a0)
	
	lea	copperlist(pc),a0	
	move.w	d1,bitplaneptr-copperlist+6(a0)
	swap	d1
	move.w	d1,bitplaneptr-copperlist+2(a0)
	swap	d1
	addi.l	#40*256,d1
	move.w	d1,bitplaneptr-copperlist+14(a0)
	swap	d1
	move.w	d1,bitplaneptr-copperlist+10(a0)
	swap	d1
	addi.l	#40*256,d1
	move.w	d1,bitplaneptr-copperlist+22(a0)
	swap	d1
	move.w	d1,bitplaneptr-copperlist+18(a0)
	swap	d1
	addi.l	#40*256,d1
	move.w	d1,bitplaneptr-copperlist+30(a0)
	swap	d1
	move.w	d1,bitplaneptr-copperlist+26(a0)

	;---- sync

	;move.w	#0,$180(a6)



.wvbl	btst.b	#6,2(a6)
	bne.b	.wvbl
	move.l	$4(a6),d0
	andi.l	#$1ff00,d0
	cmpi.l	#$13700,d0
	bne.b	.wvbl

	;move.w	#$543,$180(a6)
	
	;----

	btst.b	#6,$bfe001
	bne.w	mainloop
	
	rts

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
	
.plane2	lea	40*256(a0),a0
	ror.b	#1,d6
	bcc.b	.plane3
.wblt1	btst.b	#6,2(a6)
	bne.b	.wblt1
	move.w	d1,$52(a6)	
	movem.w	d0/d5,$40(a6)
	move.l	a0,$48(a6)
	move.l	a0,$54(a6)
	move.w	d3,$58(a6)	

.plane3	lea	40*256(a0),a0
	ror.b	#1,d6
	bcc.b	.done
.wblt2	btst.b	#6,2(a6)
	bne.b	.wblt2
	move.w	d1,$52(a6)	
	movem.w	d0/d5,$40(a6)
	move.l	a0,$48(a6)
	move.l	a0,$54(a6)
	move.w	d3,$58(a6)	
	
.done	rts

	;---- plot

plot	movem.l	d0-d2/a0,-(sp)
	move.l	doublebuffer(pc),a0
	lea	40*256*3(a0),a0
	addi.w	#320/2,d0
	addi.w	#256/2,d1
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
	dc.w	$100,$4200
	dc.w	$102,0
	dc.w	$104,0
	;dc.w	$180,0
	dc.w	$182,$f00
	dc.w	$184,$0f0
	dc.w	$186,$00f
	dc.w	$188,$555
	dc.w	$18a,$500
	dc.w	$18c,$050
	dc.w	$18e,$005
	dc.w	$190,$fff
	dc.w	$192,$fff
	dc.w	$194,$fff
	dc.w	$196,$fff
	dc.w	$198,$fff
	dc.w	$19a,$fff
	dc.w	$19c,$fff
	dc.w	$19e,$fff
	dc.w	$1a0,$fff

bitplaneptr
	dc.w	$e0,0
	dc.w	$e2,0
	dc.w	$e4,0
	dc.w	$e6,0
	dc.w	$e8,0
	dc.w	$ea,0
	dc.w	$ec,0
	dc.w	$ee,0
	
	dc.l	-2

	;----

doublebuffer
	dc.l	bitplane1
	dc.l	bitplane2

	;----
	
alpha	dc.w	40	; z rotate angle
beta	dc.w	40	; x rotate angle
theta	dc.w	40	; y rotate angle

	;---- 3d datas
	
boxsize	equ	30
	
cube_vertex
	dc.w	8
	dc.w	-boxsize,	boxsize,	boxsize
	dc.w	boxsize,	boxsize,	boxsize
	dc.w	boxsize,	-boxsize,	boxsize
	dc.w	-boxsize,	-boxsize,	boxsize
	
	dc.w	-boxsize,	boxsize,	-boxsize
	dc.w	boxsize,	boxsize,	-boxsize
	dc.w	boxsize,	-boxsize,	-boxsize
	dc.w	-boxsize,	-boxsize,	-boxsize
	
cube_rotated
	ds.w	8*4

cube_2d	ds.w	8*4
	
cube_vectors
	dc.w	12		; line count
	
	dc.w	0,1,0,0		; p1,p2,colour,flags
	dc.w	1,2,0,0
	dc.w	2,3,0,0
	dc.w	3,0,0,0
	
	dc.w	5,4,0,0
	dc.w	4,7,0,0
	dc.w	7,6,0,0
	dc.w	6,5,0,0
	
	dc.w	0,4,0,0
	dc.w	1,5,0,0
	dc.w	2,6,0,0
	dc.w	3,7,0,0	

cube_cutpoint
	ds.w	12*4		; cut point for each vector

cube_faces
	dc.w	6
	dc.w	4,	1,	1,2,3,4
	dc.w	4,	1,	5,6,7,8
	dc.w	4,	2,	-5,-10,-1,9
	dc.w	4,	2,	-3,11,-7,-12
	dc.w	4,	3,	-9,-4,12,-6
	dc.w	4,	3,	10,-8,-11,-2

	;---- cut plane

planesize	EQU	80
	
plane_vertex
	dc.w	4
	dc.w	-planesize,	planesize,	0
	dc.w	planesize,	planesize,	0
	dc.w	planesize,	-planesize,	0
	dc.w	-planesize,	-planesize,	0

plane_rotated
	ds.w	4*4

plane_vectors
	dc.w	4		; line count
	dc.w	0,1,4,0		; p1,p2,colour
	dc.w	1,2,4,0
	dc.w	2,3,4,0
	dc.w	3,0,4,0

plane_params
	ds.w	3
	ds.l	1

a	ds.w	1
b	ds.w	1
c	ds.w	1

	dc.b	'sebo'

	;---- maths tables
		
sincos16
	incbin	sincos16
	
	;---- bitplanes
	
bitplane1
	ds.w	20*256*4
	
bitplane2
	ds.w	20*256*4
	
