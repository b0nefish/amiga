
	SECTION	shadow,CODE_C

	include	/shadow-vec/startup.s
	
mainloop

	;---------------------------------------------------
	;--- clear bitmaps

clear	btst.b	#6,2(a6)
	bne.b	clear

	move.l	doublebuffer(pc),$54(a6)
	move.l	#(%100000000)<<16,$40(a6)
	clr.w	$66(a6)	
	move.w	#((200*4)<<6)+20,$58(a6)	
	
	;---------------------------------------------------
	;---- rotate cube
	
rotate_cube
	lea	cube(pc),a0
	lea	cube_rotated(pc),a1
	lea	cube_screened(pc),a2
	lea	sincos16(pc),a3
	lea	90*2(a3),a4
	move.w	(a0)+,d7
	subq.w	#1,d7

_sin	EQUR	a3
_cos	EQUR	a4

.loop	movem.w	(a0)+,d0-d2

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

	;----

	movem.w	world(pc),d3-d5	;
	add.w	d3,d0		;
	add.w	d4,d1		;
	add.w	d5,d2		;
	movem.w	d0-d2,(a1)	; push 3d rotated point
	lea	8(a1),a1	;
	
	;---- screening
	
	move.w	d2,d3		; project 3d world on screen
	addi.w	#256,d3		;
	beq.b	.origin		;
	ext.l	d0		;
	ext.l	d1		;
	asl.l	#8,d0		;
	asl.l	#8,d1		;
	divs.w	d3,d0		;
	divs.w	d3,d1		;

	;----

.origin	addi.w	#320/2,d0	;
	addi.w	#200/2,d1	;
	movem.w	d0-d2,(a2)	;
	lea	8(a2),a2	; push 2d rotated point
	dbf	d7,.loop	; rotate next point

	;---------------------------------------------------
	;---- rotate light

rotate_light
	lea	light_rotated(pc),a0
	movem.w	light(pc),d0-d2

	move.w	gamma(pc),d4	;
	add.w	d4,d4		;
	move.w	(_sin,d4.w),d3	; d3 = sin(gamma)
	move.w	(_cos,d4.w),d4	; d4 = cos(gamma)
	move.w	d3,d5		;
	move.w	d4,d6		;
	
	muls.w	d0,d4		; 
	muls.w	d2,d3		; 
	muls.w	d2,d6		; 
	muls.w	d0,d5		; 
	sub.l	d3,d4		;
	add.l	d5,d6		;
	add.l	d4,d4		;
	add.l	d6,d6		;
	swap	d4		;
	swap	d6		;
	move.w	d4,d0		; 
	move.w	d6,d2		; 
	
	movem.w	d0-d2,(a0)	;
	
	;---------------------------------------------------
	;---- cube normals

normals	lea	cube_rotated(pc),a0
	lea	cube_vectors+2(pc),a1
	lea	cube_faces(pc),a2
	lea	cube_normals(pc),a3
	
	move.w	(a2)+,d7	;
	subq.w	#1,d7		; faces count

.loop	move.w	4(a2),d6	; line index
	bpl.b	.a		;			
	neg.w	d6		;
.a	lsl.w	#3,d6		;		
	movem.w	-8(a1,d6.w),d5/d6
	lsl.w	#3,d5		;
	lsl.w	#3,d6		;
	tst.w	4(a2)		;
	bpl.b	.b		;
	exg	d5,d6		;
.b	movem.w	(a0,d5.w),d0-d2	;
	sub.w	0(a0,d6.w),d0	; ux = (x1-x2)
	sub.w	2(a0,d6.w),d1	; uy = (y1-y2)
	sub.w	4(a0,d6.w),d2	; uz = (z1-z2)

	move.w	6(a2),d6	; line index		
	bpl.b	.c		;
	neg.w	d6		;
.c	lsl.w	#3,d6		;		
	movem.w	-8(a1,d6.w),d5/d6
	lsl.w	#3,d5		;
	lsl.w	#3,d6		;
	tst.w	6(a2)		;
	bpl.b	.d		;
	exg	d5,d6		;
.d	movem.w	(a0,d5.w),d3-d5	;
	sub.w	0(a0,d6.w),d3	; vx = (x3-x2)
	sub.w	2(a0,d6.w),d4	; vy = (y3-y2)
	sub.w	4(a0,d6.w),d5	; vz = (y3-y2)

ux	EQUR	d0
uy	EQUR	d1
uz	EQUR	d2
vx	EQUR	d3
vy	EQUR	d4
vz	EQUR	d5

	move.l	d7,-(sp)
	
	move.w	uy,d6		;
	move.w	vy,d7		;
	muls.w	vz,d6		;
	muls.w	uz,d7		;
	sub.l	d7,d6		;
	move.l	d6,(a3)+	;

	move.w	uz,d6		;
	move.w	vz,d7		;		
	muls.w	vx,d6		;
	muls.w	ux,d7		;
	sub.l	d7,d6		;
	move.l	d6,(a3)+	;

	move.w	ux,d6		;
	move.w	vx,d7		;
	muls.w	vy,d6		;
	muls.w	uy,d7		;
	sub.l	d7,d6		;
	move.l	d6,(a3)+	;

	move.l	(sp)+,d7
	
	move.w	(a2),d0		; 
	add.w	d0,d0		;
	lea	4(a2,d0.w),a2	; update face pointer
	dbf	d7,.loop	; next face

	;---------------------------------------------------
	;---- draw cube
	
draw	lea	cube_screened(pc),a0
	lea	cube_vectors+2(pc),a1
	lea	cube_faces(pc),a2
	move.w	(a2)+,d7
	subq.w	#1,d7

.loop	move.l	(a2)+,d6
	swap	d6		; d6 = [colour].w [linecount].w
	subq.w	#1,d6
		
	;---- vector product
	
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
	sub.w	0(a0,d5.w),d0		; x1 - x2
	sub.w	2(a0,d5.w),d1		; y1 - y2

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
	sub.w	0(a0,d5.w),d2		; x4 - x3
	sub.w	2(a0,d5.w),d3		; y4 - y3

	muls.w	d3,d0
	muls.w	d2,d1
	sub.l	d1,d0
	
	;---- line xor
	
.xor	swap	d6		;
	move.w	(a2)+,d1	;		
	bpl.b	.plus		;
	neg.w	d1		;
.plus 	lsl.w	#3,d1		;
	tst.l	d0		; check visibility
	bmi.b	.next		;		
	eor.w	d6,4-8(a1,d1.w)	;
.next	swap	d6		;
	dbf	d6,.xor		;	
	dbf	d7,.loop	;

	;---- draw the cube

draw_cube
	lea	cube_vectors(pc),a1
	lea	cube_screened(pc),a2
	move.w	(a1)+,d7
	subq.w	#1,d7

.wblt1	btst.b	#6,2(a6)
	bne.b	.wblt1

	move.w	#40,$60(a6)
	move.w	#40,$66(a6)
	move.l	#$ffff8000,$72(a6)
	move.l	#$ffffffff,$44(a6)

.loop	movem.w	(a1)+,d4-d5	;
	move.w	(a1)+,d6	;
	beq.w	.next		;
	lsl.w	#3,d4		;
	lsl.w	#3,d5		;
	movem.w	(a2,d4.w),d0/d1	;
	movem.w	(a2,d5.w),d2/d3	;
	clr.w	-2(a1)		; clear colour

	;---- line draw
	
	moveq	#0,d5
	cmp.w	d1,d3
	beq.w	.next
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
	mulu.w	#40,d1
	add.w	d4,d1	
	lea	(a0,d1.w),a0
	andi.w	#$f,d0
	add.w	d0,d0
	add.w	d2,d2		; d2 = 2pdelta
.wblt2	btst.b	#6,2(a6)
	bne.b	.wblt2
	move.w	d2,$62(a6)	; bltbmod
	sub.w	d3,d2		; 2pdelta - gdelta	
	bpl.b	.aptl
	addq.b	#8,d5
.aptl	move.w	d2,d1				
	sub.w	d3,d2				
	move.w	d2,$64(a6)			
	move.w	.bltcon0(pc,d0.w),d0		
	move.w	.bltcon1(pc,d5.w),d5		
	lsl.w	#6,d3
	addq.w	#2,d3
	bra.b	.plane0
	
	;----

LF	EQU	($f0&$55)+($0f&$aa)	; A XOR C

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

.plane0	btst	#0,d6
	beq.b	.plane1
	move.w	d1,$52(a6)	
	movem.w	d0/d5,$40(a6)
	move.l	a0,$48(a6)
	move.l	a0,$54(a6)
	move.w	d3,$58(a6)	
	
.plane1	lea	40*200(a0),a0
	btst	#1,d6
	beq.b	.plane2
.wblt3	btst.b	#6,2(a6)
	bne.b	.wblt3
	move.w	d1,$52(a6)	
	movem.w	d0/d5,$40(a6)
	move.l	a0,$48(a6)
	move.l	a0,$54(a6)
	move.w	d3,$58(a6)	

.plane2	lea	40*200(a0),a0
	btst	#2,d6
	beq.b	.next
.wblt4	btst.b	#6,2(a6)
	bne.b	.wblt4
	move.w	d1,$52(a6)	
	movem.w	d0/d5,$40(a6)
	move.l	a0,$48(a6)
	move.l	a0,$54(a6)
	move.w	d3,$58(a6)	
	
.next	lea	2(a1),a1
	dbf	d7,.loop

	;---------------------------------------------------
	;---- blitter fill

fill1	move.l	doublebuffer(pc),a0
	lea	(40*200*3)-2(a0),a0
	
.wblt	btst.b	#6,2(a6)
	bne.b	.wblt
	
	move.l	a0,$50(a6)
	move.l	a0,$54(a6)
	clr.l	$64(a6)	
	move.l	#(((%1001<<8)+%11110000)<<16)+%10010,$40(a6)
	move.w	#((200*3)<<6)+20,$58(a6)	

	;---------------------------------------------------
	;---- scalar
	
scalar	lea	cube_normals(pc),a0
	lea	cube_scalar(pc),a1
	move.w	cube_faces(pc),d7
	subq.w	#1,d7
	
	movem.w	world(pc),d0-d2
	movem.w	light_rotated(pc),d3-d5	
	sub.w	d3,d0		
	sub.w	d4,d1		 
	sub.w	d5,d2		
		
.loop	movem.l	(a0)+,d3-d5	;	
	muls.w	d0,d3		;
	muls.w	d1,d4		;
	muls.w	d2,d5		;
	add.l	d5,d4		;
	add.l	d4,d3		; scalar
	move.l	d3,(a1)+	;
	dbf	d7,.loop	;

	;---------------------------------------------------
	;---- face lightning

lightning
	lea	cube_faces(pc),a0
	lea	cube_scalar(pc),a1
	lea	cube_normals(pc),a2
	lea	palette(pc),a3
	lea	cube_exposure(pc),a4

	movem.w	world(pc),d0-d2
	movem.w	light_rotated(pc),d3-d5	 
	sub.w	d3,d0		;
	sub.w	d4,d1		;
	sub.w	d5,d2		;
	cmpi.w	#boxsize*2,d1	;
	ble.w	moveangles	;
	muls.w	d0,d0		;
	muls.w	d1,d1		;
	muls.w	d2,d2		;
	add.l	d2,d1		;
	add.l	d1,d0		;
	jsr	sqrt(pc)	; light vector length
	move.w	d2,d6		;
	
	move.w	(a0)+,d7	; faces count
	subq.w	#1,d7		;
	
.loop	movem.l	(a2)+,d0-d2	; normal vector		
	muls.w	d0,d0		;
	muls.w	d1,d1		;
	muls.w	d2,d2		;
	add.l	d2,d1		;
	add.l	d1,d0		;
	jsr	sqrt(pc)	; normal vector length
	
	move.l	(a1),d1		;
	mulu.w	d6,d2		; |vl| * |vn|
	lsr.l	#6,d2		;
	beq.b	.zero		;
	divs.w	d2,d1		; cos(a) = (vl.vn) / (|vl| * |vn|) 

.zero	move.w	2(a0),d0	; get colour index
	lsl.w	#2,d0		;
	clr.w	-4+2(a3,d0.w)	; reset face colour

	move.w	d1,(a4)+	; push exposure
	bmi.b	.next		; cos(a) < 0 ?

	move.w	#15,d2		; R
	move.w	#5,d3		; G
	move.w	#4,d4		; B
	mulu.w	d1,d2		;
	mulu.w	d1,d3		;
	mulu.w	d1,d4		;
	lsr.w	#6,d2		;
	lsr.w	#6,d3		;
	lsr.w	#6,d4		;
	lsl.w	#8,d2		;
	lsl.w	#4,d3		;
	or.w	d3,d2		;
	or.w	d4,d2		;
	move.w	d2,-4+2(a3,d0.w)
	move.w	d2,-4+(4*8)+2(a3,d0.w)	

.next	move.w	(a0),d0		; 
	add.w	d0,d0		;
	lea	4(a0,d0.w),a0	; update face pointer
	lea	4(a1),a1	; update scalar pointer	
	dbf	d7,.loop	; next face		

	;---------------------------------------------------
	;----
	
deer	lea	cube_faces(pc),a0
	lea	cube_vectors+2(pc),a1
	lea	cube_exposure(pc),a2
	move.w	(a0)+,d7
	subq.w	#1,d7

.loop	move.l	(a0)+,d6	;
	swap	d6		;
	subq.w	#1,d6		;
.xor	move.w	(a0)+,d0	;		
	bpl.b	.plus		;
	neg.w	d0		;
.plus 	lsl.w	#3,d0		;
	cmpi.w	#10,(a2)	;
	ble.b	.next		;
	eori.w	#1,6-8(a1,d0.w)	;
.next	dbf	d6,.xor		;
	lea	2(a2),a2	;
	dbf	d7,.loop	;

	;---------------------------------------------------
	;---- face shadowing

ground	EQU	50

shadowing
	lea	cube_faces(pc),a0
	lea	cube_vectors+2(pc),a1
	lea	light_rotated(pc),a2
	lea	cube_rotated(pc),a3
	lea	shd_lines(pc),a4

	clr.w	(a4)+		; clear line count
	move.w	(a0)+,d7	; faces count
	subq.w	#1,d7		;

.loop1	swap	d7		;
	move.w	(a0),d7		; line count
	subq.w	#1,d7		;
	lea	4(a0),a0	;
	
.loop2	move.w	(a0)+,d0	; line index
	bpl.b	.plus		;			
	neg.w	d0		;
.plus	lsl.w	#3,d0		;
	lea	-8(a1,d0.w),a5	;
	
	move.w	6(a5),d0	; line hidden ?
	beq.w	.hide		;
	clr.w	6(a5)		; reset shadow colour index

	moveq	#2-1,d5		;
	
.loop3	move.w	(a5)+,d0	; get point
	lsl.w	#3,d0		;
	movem.w	(a3,d0.w),d0-d2	; (x,y,z)
	sub.w	0(a2),d0	; dx
	sub.w	2(a2),d1	; dy
	sub.w	4(a2),d2	; dz	
	move.w	#ground,d3	;
	sub.w	2(a2),d3	; yground - ylight
	muls.w	d3,d0		;
	muls.w	d3,d2		;
	divs.w	d1,d0		;
	divs.w	d1,d2		;
	add.w	0(a2),d0	; x'
	add.w	4(a2),d2	; z'
	move.w	#ground,d1	; y'
	movem.w	d0-d2,(a4)	;	
	lea	6(a4),a4	;	
	dbf	d5,.loop3	;
	
	lea	shd_lines(pc),a5;
	addq.w	#1,(a5)		;
.hide	dbf	d7,.loop2	; next line
	
	swap	d7		;
	bra.b	.ii		;
	
.next	move.w	(a0),d0		; 
	add.w	d0,d0		;
	lea	4(a0,d0.w),a0	; update face pointer	
.ii	dbf	d7,.loop1	; next face		

	;---------------------------------------------------		
	;---- draw shadow
	
drawshadow
	lea	shd_lines(pc),a0
	move.l	doublebuffer(pc),a1
	lea	40*200*3(a1),a1
	lea	border(pc),a2
	move.w	(a0)+,d7
	subq.w	#1,d7
	bmi.w	.fill

.wblt1	btst.b	#6,2(a6)
	bne.b	.wblt1

	move.w	#40,$60(a6)
	move.w	#40,$66(a6)
	move.l	#$ffff8000,$72(a6)
	move.l	#$ffffffff,$44(a6)
	
.loop	movem.w	(a0)+,d0-d5	; (x1,y1,z1) (x2,y2,z2)

	;---- z-clipping

zclip	EQU	-200
	
	cmp.l	d2,d5		;
	bge.b	.zclip		;
	exg	d0,d3		;
	exg	d1,d4		;
	exg	d2,d5		;
	
.zclip	cmpi.w	#zclip,d5	;
	ble.w	.done		; line behind view plane		
	cmpi.w	#zclip,d2	;
	bge.b	.screening	;
	
	move.w	#zclip,d2	; fix z
	
	;---- screening

.screening
	asl.l	#8,d0		;
	asl.l	#8,d1		;
	asl.l	#8,d3		;
	asl.l	#8,d4		;
	addi.w	#256,d2		;
	beq.b	.zero1		;
	divs.w	d2,d0		; 
	divs.w	d2,d1		; 
.zero1	addi.w	#256,d5		;
	beq.b	.zero2		;
	divs.w	d5,d3		; 
	divs.w	d5,d4		; 
.zero2	addi.w	#320/2,d0	; x1'
	addi.w	#200/2,d1	; y1'
	addi.w	#320/2,d3	; x2'
	addi.w	#200/2,d4	; y2'
	move.w	d3,d2		;
	move.w	d4,d3		;

	;---- clipping

clipleft	equ	0
clipright	equ	320-1
cliptop		equ	0
clipbottom	equ	200-1

	;---- test if vector is outside
	
	cmp.w	d1,d3		;
	bge.b	.a		;
	exg	d0,d2		;
	exg	d1,d3		;
.a	cmpi.w	#clipbottom,d1	;
	bgt.w	.done		;
	
	cmp.w	d0,d2		;
	bge.b	.b		;
	exg	d0,d2		;
	exg	d1,d3		;
.b	cmpi.w	#clipleft,d2	;
	blt.w	.done		;
	cmpi.w	#clipright,d0	;
	bgt.w	.done		;
	
	;---- test left window border
	
.left	cmpi.w	#clipleft,d0	;
	bge.b	.right		;
	move.w	d2,d4		;
	move.w	d3,d5		;
	sub.w	d0,d4		; dx
	sub.w	d1,d5		; dy
	move.w	#clipleft,d6	;
	sub.w	d0,d6		; 
	muls.w	d5,d6		; 
	divs.w	d4,d6		; 
	add.w	d6,d1		; y1 + dy(clipleft-x1) / dx
	move.w	#clipleft,d0	;
	
	;---- test right window border
	
.right	cmpi.w	#clipright,d2	;
	ble.b	.c		;
	move.w	d2,d4		;
	move.w	d3,d5		;
	sub.w	d0,d4		; dx
	sub.w	d1,d5		; dy
	move.w	#clipright,d6	;
	sub.w	d2,d6		;
	muls.w	d5,d6		;
	divs.w	d4,d6		; 
	add.w	d6,d3		; y2 + dy(clipright-x2) / dx
	move.w	#clipright,d2	;
	
	;----
		
.border	cmpi.w	#cliptop,d3	;
	bge.b	.e		;
	move.w	#cliptop,d3	;
.e	cmpi.w	#clipbottom,d3	;
	bgt.b	.c		;
	not.b	(a2,d3.w)	;

	;----

.c	cmp.w	d1,d3		;
	bge.b	.top		;
	exg	d0,d2		;
	exg	d1,d3		;
	
	;---- test top window border
	
.top	cmpi.w	#cliptop,d1	;
	bge.b	.bottom		;
	cmpi.w	#cliptop,d3	;
	ble.w	.done		;
	move.w	d2,d4		;
	move.w	d3,d5		;
	sub.w	d0,d4		;	
	sub.w	d1,d5		;
	move.w	#cliptop,d6	;
	sub.w	d1,d6		;
	muls.w	d4,d6		;
	divs.w	d5,d6		; 
	add.w	d6,d0		; x1 + dx(cliptop-y1) / dy
	move.w	#cliptop,d1	;

	;---- test bottom window border

.bottom	cmpi.w	#clipbottom,d3	;
	ble.b	.draw		;
	cmpi.w	#clipbottom,d1	;
	bgt.w	.done		;
	move.w	d2,d4		;
	move.w	d3,d5		;
	sub.w	d0,d4		;	
	sub.w	d1,d5		; 
	move.w	#clipbottom,d6	;
	sub.w	d3,d6		; 
	muls.w	d4,d6		;
	divs.w	d5,d6		; 
	add.w	d6,d2		; x2 + dx(clipbottom-y2) / dy
	move.w	#clipbottom,d3	;
	
	;---- line draw

.draw	moveq	#0,d5
	cmp.w	d1,d3
	beq.b	.done
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
.ptr	move.w	d0,d4
	lsr.w	#3,d4
	mulu.w	#40,d1
	add.w	d4,d1
	lea	(a1,d1.w),a3
	andi.w	#$f,d0
	add.w	d0,d0
	add.w	d2,d2		; d2 = 2pdelta
.wblt2	btst.b	#6,2(a6)
	bne.b	.wblt2
	move.w	d2,$62(a6)	; bltbmod
	sub.w	d3,d2		; 2pdelta - gdelta	
	bpl.b	.aptl
	addq.b	#8,d5
.aptl	move.w	d2,$52(a6)
	sub.w	d3,d2
	move.w	d2,$64(a6)
	move.w	.bltcon0(pc,d0.w),$40(a6)
	move.w	.bltcon1(pc,d5.w),$42(a6)
	move.l	a3,$48(a6)
	move.l	a3,$54(a6)
	lsl.w	#6,d3
	addq.w	#2,d3
	move.w	d3,$58(a6)
.done	dbf	d7,.loop	; next line
	bra.b	.fill

	;----

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

.fill	btst.b	#6,2(a6)
	bne.b	.fill

	lea	40-1(a1),a0
	move.w	#200-2,d7
	moveq	#1,d0
	swap	d0
.loop2	tst.b	(a2)
	beq.b	.false
	swap	d0
	clr.b	(a2)
.false	eor.b	d0,(a0)
	lea	40(a0),a0
	lea	1(a2),a2
	dbf	d7,.loop2

	;----

	lea	(40*200)-2(a1),a1	
	move.l	a1,$50(a6)
	move.l	a1,$54(a6)
	clr.l	$64(a6)	
	move.l	#(((%1001<<8)+%11110000)<<16)+%10010,$40(a6)
	move.w	#(90<<6)+20,$58(a6)	

	;---------------------------------------------------
	;---- angles
	
moveangles
	movem.w	alpha(pc),d0-d3
	move.w	#360,d4
	addq.w	#2,d0
	addq.w	#1,d1
	addq.w	#3,d2
	addq.w	#1,d3
	
.clip1	cmp.w	d4,d0
	blt.b	.clip2
	moveq	#0,d0

.clip2	cmp.w	d4,d1
	blt.b	.clip3
	moveq	#0,d1
	
.clip3	cmp.w	d4,d2
	blt.b	.clip4
	moveq	#0,d2

.clip4	cmp.w	d4,d3
	blt.b	.done
	moveq	#0,d3
	
.done	movem.w	d0-d3,alpha

	;---- vbl sync

	move.w	#6,$180(a6)
		
sync	btst.b	#6,2(a6)
	bne.b	sync
	move.l	4(a6),d0
	andi.l	#$1ff00,d0
	cmpi.l	#$13800,d0
	bne.b	sync

	move.w	#$fff,$180(a6)

	;---- screen swap

	lea	doublebuffer(pc),a0
	movem.l	(a0),d0-d1
	exg	d0,d1
	movem.l	d0-d1,(a0)
	
	lea	copperlist(pc),a0	
	move.l	#40*200,d0

	move.w	d1,bitplaneptr-copperlist+6(a0)
	swap	d1
	move.w	d1,bitplaneptr-copperlist+2(a0)
	swap	d1

	add.l	d0,d1
	move.w	d1,bitplaneptr-copperlist+14(a0)
	swap	d1
	move.w	d1,bitplaneptr-copperlist+10(a0)
	swap	d1

	add.l	d0,d1
	move.w	d1,bitplaneptr-copperlist+22(a0)
	swap	d1
	move.w	d1,bitplaneptr-copperlist+18(a0)
	swap	d1

	add.l	d0,d1
	move.w	d1,bitplaneptr-copperlist+30(a0)
	swap	d1
	move.w	d1,bitplaneptr-copperlist+26(a0)

	;----
	
	btst.b	#6,$bfe001
	bne.w	mainloop
	
	;----
	
	rts

	;---------------------------------------------------
	;---- d2 = sqrt(d0)

sqrt	tst.l	d0		; d0 > 0 ?
	ble.b	.done		;
				
	movem.l	d0-d1/d3,-(sp)	;
	moveq	#31,d1		;
	moveq	#0,d2		;
	moveq	#0,d3		;

.log2	btst	d1,d0		;
	dbne	d1,.log2	; log2(a)
	lsr.w	#1,d1		;
	addx.w	d3,d1		;
	bset	d1,d2		; x0 = 2^(log2(a)/2)
	
	REPT	2		; iterations
	move.l	d0,d1		;
	divu.w	d2,d1		;
	add.w	d1,d2		;
	lsr.w	#1,d2		;
	addx.w	d3,d2		; xi+1 = 1/2(xi + a/xi)	
	ENDR			;
	
	movem.l	(sp)+,d0-d1/d3	;
	rts			;
	
.done	moveq	#0,d2		;
	rts			;
			
	;----

copperlist
	dc.w	$8e,$2c81
	dc.w	$90,$2cc1
	dc.w	$92,$38
	dc.w	$94,$d0
	dc.w	$100,$4200
	dc.w	$102,0
	dc.w	$108,0
	dc.w	$10a,0

bitplaneptr
	dc.w	$e0,0
	dc.w	$e2,0
	dc.w	$e4,0
	dc.w	$e6,0	
	dc.w	$e8,0
	dc.w	$ea,0	
	dc.w	$ec,0
	dc.w	$ee,0	
	
palette	dc.w	$182,$f00
	dc.w	$184,$ff0
	dc.w	$186,$f0f
	dc.w	$188,$00f
	dc.w	$18a,$0ff
	dc.w	$18c,$fff
	dc.w	$18e,0
	dc.w	$190,0
	dc.w	$192,0
	dc.w	$194,0
	dc.w	$196,0
	dc.w	$198,0
	dc.w	$19a,0
	dc.w	$19c,0
	dc.w	$19e,0
	
	dc.w	$f401,$fffe
	dc.w	$100,$0200

	dc.l	-2

	;----

doublebuffer
	dc.l	bitplane1
	dc.l	bitplane2

	;---- world

xworld	EQU	0
yworld	EQU	-20
zworld	EQU	30

world	dc.w	xworld		; translation
	dc.w	yworld		;
	dc.w	zworld		;

alpha	ds.w	1		; rotation
beta	ds.w	1		; 
theta	ds.w	1		;
gamma	ds.w	1 
	
	;---- 

lghtlen	ds.w	1

	;---- 3d coordinates

boxsize	EQU	40
	
cube	dc.w	8
	dc.w	-boxsize,	boxsize,	boxsize
	dc.w	boxsize,	boxsize,	boxsize
	dc.w	boxsize,	-boxsize,	boxsize
	dc.w	-boxsize,	-boxsize,	boxsize
	
	dc.w	-boxsize,	boxsize,	-boxsize
	dc.w	boxsize,	boxsize,	-boxsize
	dc.w	boxsize,	-boxsize,	-boxsize
	dc.w	-boxsize,	-boxsize,	-boxsize

light	dc.w	150, -110, 150

	;----
	
cube_rotated
	ds.w	8*4

cube_screened
	ds.w	8*4
	
cube_vectors
	dc.w	12		; line count
	
	dc.w	0,1,0,0		; p1,p2
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

cube_faces
	dc.w	6
	dc.w	4,	1,	1,2,3,4
	dc.w	4,	2,	5,6,7,8
	dc.w	4,	3,	-5,-10,-1,9
	dc.w	4,	4,	-3,11,-7,-12
	dc.w	4,	5,	-9,-4,12,-6
	dc.w	4,	6,	10,-8,-11,-2
	
cube_normals
	ds.l	6*3

cube_scalar
	ds.l	6

cube_exposure
	ds.w	6

light_rotated
	ds.w	3
	
shd_lines
	ds.w	1
	ds.w	500
	
border	ds.b	300
	
	;---- maths table
		
sincos16
	incbin	sincos16
	
	;---- bitmaps

bitplane1
	ds.w	20*200*4
	
bitplane2
	ds.w	20*200*4
	
