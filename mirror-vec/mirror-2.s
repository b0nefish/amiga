
	SECTION	mirror,CODE_C

	include	/mirror-vec/startup.s

height	EQU	160
zobs	EQU	-256

mainloop
	
	;---- clear bitmap

	move.l	doublebuffer(pc),a0
	;lea	10(a0),a0
	move.l	a0,$54(a6)
	move.l	#(%100000000)<<16,$40(a6)
	move.w	#0,$66(a6)	
	move.w	#((height*5)<<6)+20,$58(a6)

	;---- cube 3d rotations

rotate_cube	
	lea	cube_vertex(pc),a0
	lea	cube_rotated(pc),a1
	lea	sincos16(pc),a2
	lea	90*2(a2),a3
	move.w	(a0)+,d7
	subq.w	#1,d7

_sin	EQUR	a2
_cos	EQUR	a3

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

	;---- projection
	
	move.w	d2,d3		;
	subi.w	#zobs,d3	;
	beq.b	.done		;
	moveq	#8+3,d4		; k = 8 (scaling value)
	asl.w	#3,d3		; 
	ext.l	d0		;
	ext.l	d1		;
	asl.l	d4,d0		;
	asl.l	d4,d1		;
	divs.w	d3,d0		; P'x = - k(Px * Oz) / k(Pz - Oz)  
	divs.w	d3,d1		; P'y = - k(Py * Oz) / k(Pz - Oz)
.done	movem.w	d0-d2,(a1)	; push rotated + projected point

	lea	8(a1),a1	;
	dbf	d7,.loop	;
 
	;---- mirror rotations

rotate_mirror	
	lea	mirror_vertices(pc),a0
	lea	mirror_rotated(pc),a1
	move.w	(a0)+,d7
	subq.w	#1,d7

.loop	movem.w	(a0)+,d0-d2

.z_rotate
	move.w	phi1(pc),d4
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
	move.w	phi2(pc),d4
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
	move.w	phi3(pc),d4
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
	
	move.w	d2,d3		;
	subi.w	#zobs,d3	;
	beq.b	.done		;
	moveq	#8+3,d4		; k = 8 (scaling value)
	asl.w	#3,d3		; 
	ext.l	d0		;
	ext.l	d1		;
	asl.l	d4,d0		;
	asl.l	d4,d1		;
	divs.w	d3,d0		; P'x = - k(Px * Oz) / k(Pz - Oz)  
	divs.w	d3,d1		; P'y = - k(Py * Oz) / k(Pz - Oz)
.done	movem.w	d0-d2,(a1)	; push rotated + projected point

	lea	8(a1),a1	;
	dbf	d7,.loop	;
	
	;---- face visibility
	
hidden	lea	cube_rotated(pc),a0
	lea	cube_vectors+2(pc),a1
	lea	cube_faces(pc),a2
	move.w	(a2)+,d7
	subq.w	#1,d7		; d7 = face count

.loop	move.l	(a2)+,d6	;
	swap	d6		; d6 = [color].w [linecount].w
	subq.w	#1,d6		;

	lea	0(a2),a3	;
	lea	2(a2),a2	;
	bclr.b	#0,(a3)		; clear visibility flag
		
	;----
	
	move.w	0(a2),d5
	bpl.b	.a			
	neg.w	d5
.a	lsl.w	#4,d5				
	movem.w	-16(a1,d5.w),d4/d5
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
.c	lsl.w	#4,d5				
	movem.w	-16(a1,d5.w),d4/d5
	lsl.w	#3,d4
	lsl.w	#3,d5
	tst.w	2(a2)
	bpl.b	.d
	exg	d4,d5
.d	movem.w	(a0,d4.w),d2/d3
	sub.w	0(a0,d5.w),d2	; x4 - x3
	sub.w	2(a0,d5.w),d3	; y4 - y3

	muls.w	d3,d0		;
	muls.w	d2,d1		;
	sub.l	d1,d0		; face normal z-component
	bmi.b	.xoring		; is the face visible (Nz > 0) ?
	bset.b	#0,(a3)		; yes => set visibility flag
	
	;---- edge xoring
	
.xoring	swap	d6		;
	move.w	(a2)+,d1	;		
	bpl.b	.e		;
	neg.w	d1		;
.e	tst.l	d0		;
	bmi.b	.next		;
	lsl.w	#4,d1		;
	eor.w	d6,-8(a1,d1.w)	; update line color
.next	swap	d6		;
	dbf	d6,.xoring	;
	dbf	d7,.loop	;

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

.loop	movem.w	0(a1),d4-d5		; get points
	move.w	8(a1),d6		; get line color
	beq.b	.next			;
	lsl.w	#3,d4			;
	lsl.w	#3,d5			;
	movem.w	(a2,d4.w),d0/d1		; PA
	movem.w	(a2,d5.w),d2/d3		; PB
	addi.w	#320/2,d0		; Ax
	addi.w	#height/2,d1		; Ay
	addi.w	#320/2,d2		; Bx
	addi.w	#height/2,d3		; By
	clr.w	8(a1)			; clear color index
	jsr	draw1px(pc)		;
.next	lea	16(a1),a1		;
	dbf	d7,.loop		;
 
	;---- draw plane

draw_plane
	lea	mirror_vectors(pc),a1
	lea	mirror_rotated(pc),a2
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
	addi.w	#height/2,d1
	addi.w	#320/2,d2
	addi.w	#height/2,d3
	jsr	draw1px(pc)
.next	lea	2(a1),a1
	dbf	d7,.loop
 
	;---- fill cube and mirror plane

fill_pass_1
	move.l	doublebuffer(pc),a0
	lea	(40*height*3)-2-10(a0),a0
.wblt	btst.b	#6,2(a6)
	bne.b	.wblt
	move.l	a0,$50(a6)
	move.l	a0,$54(a6)
	move.w	#20,$64(a6)
	move.w	#20,$66(a6)	
	move.l	#(((%1001<<8)+%11110000)<<16)+%10010,$40(a6)
	move.w	#((height*3)<<6)+10,$58(a6)	

	;----

	lea	bplcon2(pc),a0
	lea	colors(pc),a1
	clr.w	2(a0)
	move.w	#$222,6(a1)

	;---- mirror plane parameters
	;
	; plane parametric equation :
	; Ax + By + Cz + d = 0 

plane	lea	mirror_params(pc),a0
	lea	mirror_rotated(pc),a1
	
	movem.w	8(a1),d0-d2	;
	sub.w	0(a1),d0	; x1
	sub.w	2(a1),d1	; y1
	sub.w	4(a1),d2	; z1
	
	movem.w	8(a1),d3-d5	;
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
	bpl.w	animate		; mirror reflect nothing observable

	moveq	#6,d7		; k = 64 (scaling value that fit 16 bits)
	asr.l	d7,d6		;
	asr.l	d7,d2		;
	asr.l	d7,d0		;
	move.w	d6,0(a0)	; A/k
	move.w	d2,2(a0)	; B/k 
	move.w	d0,4(a0)	; C/k
	
	muls.w	0(a1),d6	; AX/k
	muls.w	2(a1),d2	; BY/k
	muls.w	4(a1),d0	; CZ/k
	add.l	d6,d2		;
	add.l	d2,d0		;
	neg.l	d0		; d0 = d/k = -(AX + BY + CZ) / k
	move.l	d0,8(a0)	;
 
	;----

	movem.w	0(a0),d0-d2	;
	muls.w	d0,d0		;
	muls.w	d1,d1		;
	muls.w	d2,d2		;
	add.l	d2,d1		;
	add.l	d1,d0		; d0 = (A²+B²+C²) / k²
	move.w	d0,6(a0)	;

	;----
	
mirror	lea	cube_rotated(pc),a1
	lea	cube_reflected(pc),a2
	move.w	cube_vertex(pc),d7
	subq.w	#1,d7

.loop	movem.w	(a1),d0-d2	;
	muls.w	0(a0),d0	;
	muls.w	2(a0),d1	;
	muls.w	4(a0),d2	;
	add.l	d2,d1		;
	add.l	d1,d0		;
	add.l	8(a0),d0	; d0 = (Ax + By + Cz + d) / k

	movem.w	(a0),d1-d4	;
	muls.w	d0,d1		; A(Ax + By + Cz + d) / k²
	muls.w	d0,d2		; B(Ax + By + Cz + d) / k²
	muls.w	d0,d3		; C(Ax + By + Cz + d) / k²
	tst.w	d4		;
	beq.b	.zero		;
	divs.w	d4,d1		;
	divs.w	d4,d2		;
	divs.w	d4,d3		;
.zero	movem.w	(a1),d4-d6	;
	sub.w	d1,d4		; x'
	sub.w	d2,d5		; y'
	sub.w	d3,d6		; z'

	movem.w	(a1),d0-d2	;
	sub.w	d4,d0		;
	sub.w	d5,d1		;
	sub.w	d6,d2		;		
	sub.w	d0,d4		; x''	
	sub.w	d1,d5		; y''
	sub.w	d2,d6		; z''
	movem.w	d4-d6,(a2)	;

	;jsr	plot(pc)
	
	lea	8(a1),a1
	lea	8(a2),a2
	dbf	d7,.loop

	;---- face visibility
	
ttt	lea	cube_reflected(pc),a0
	lea	cube_vectors+2(pc),a1
	lea	cube_faces(pc),a2
	move.w	(a2)+,d7
	subq.w	#1,d7		; d7 = face count

.loop	move.l	(a2)+,d6	; 
	lsl.w	#3,d6		;
	swap	d6		; d6 = [color].w [linecount].w
	subq.w	#1,d6		;

	lea	0(a2),a3	;
	lea	2(a2),a2	;
	;bclr.b	#0,(a3)		; clear visibility flag
		
	;----
	
	move.w	0(a2),d5
	bpl.b	.a			
	neg.w	d5
.a	lsl.w	#4,d5				
	movem.w	-16(a1,d5.w),d4/d5
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
.c	lsl.w	#4,d5				
	movem.w	-16(a1,d5.w),d4/d5
	lsl.w	#3,d4
	lsl.w	#3,d5
	tst.w	2(a2)
	bpl.b	.d
	exg	d4,d5
.d	movem.w	(a0,d4.w),d2/d3
	sub.w	0(a0,d5.w),d2	; x4 - x3
	sub.w	2(a0,d5.w),d3	; y4 - y3

	muls.w	d3,d0		;
	muls.w	d2,d1		;
	sub.l	d1,d0		; face normal z-component
	;bmi.b	.xoring		; is the face visible (Nz > 0) ?
	;bset.b	#0,(a3)		; yes => set visibility flag
	
	;---- edge xoring
	
.xoring	swap	d6		;
	move.w	(a2)+,d1	;		
	bpl.b	.e		;
	neg.w	d1		;
.e	tst.l	d0		;
	bpl.b	.next		;
	lsl.w	#4,d1		;
	eor.w	d6,-8(a1,d1.w)	; update line color
.next	swap	d6		;
	dbf	d6,.xoring	;
	dbf	d7,.loop	;

	;---- draw mirror cube

draw_cube_mirror
	lea	cube_vectors(pc),a1
	lea	cube_reflected(pc),a2
	move.w	(a1)+,d7
	subq.w	#1,d7

.wblt	btst.b	#6,2(a6)
	bne.b	.wblt

	move.w	#40,$60(a6)		; bltcmod
	move.w	#40,$66(a6)		; bltdmod
	move.l	#$ffff8000,$72(a6)	; bltbdat + bltadat
	move.l	#$ffffffff,$44(a6)	; bltafwm + bltalwm

.loop	movem.w	0(a1),d4-d5		; get points
	move.w	8(a1),d6		; get line color
	beq.b	.next			;
	lsl.w	#3,d4			;
	lsl.w	#3,d5			;
	movem.w	(a2,d4.w),d0/d1		; PA
	movem.w	(a2,d5.w),d2/d3		; PB
	addi.w	#320/2,d0		; Ax
	addi.w	#height/2,d1		; Ay
	addi.w	#320/2,d2		; Bx
	addi.w	#height/2,d3		; By
	clr.w	8(a1)			; clear color index
	jsr	draw1px(pc)		;
.next	lea	16(a1),a1		;
	dbf	d7,.loop		;

	;---- fill reflected cube

fill_pass_2
	move.l	doublebuffer(pc),a0
	lea	(40*height*5)-2-0(a0),a0
.wblt	btst.b	#6,2(a6)
	bne.b	.wblt
	move.l	a0,$50(a6)
	move.l	a0,$54(a6)
	move.w	#0,$64(a6)
	move.w	#0,$66(a6)	
	move.l	#(((%1001<<8)+%11110000)<<16)+%10010,$40(a6)
	move.w	#((height*2)<<6)+20,$58(a6)	

	;----

	lea	bplcon2(pc),a0
	lea	colors(pc),a1
	bset.b	#6,3(a0)
	move.w	#3,6(a1)

	;---- animate
	
animate	movem.w	alpha(pc),d0-d5
	move.w	#360,d7
	addq.w	#1,d0
	addq.w	#3,d1
	addq.w	#1,d2
	;addq.w	#1,d3
	;addq.w	#2,d4
	addq.w	#1,d5
.clip1	cmp.w	d7,d0
	blt.b	.clip2
	sub.w	d7,d0
.clip2	cmp.w	d7,d1
	blt.b	.clip3
	sub.w	d7,d1
.clip3	cmp.w	d7,d2
	blt.b	.clip4
	sub.w	d7,d2
.clip4	cmp.w	d7,d3
	blt.b	.clip5
	sub.w	d7,d3
.clip5	cmp.w	d7,d4
	blt.b	.clip6
	sub.w	d7,d4
.clip6	cmp.w	d7,d5
	blt.b	.done
	sub.w	d7,d5
.done	movem.w	d0-d5,alpha

	;---- screen swap
	
	lea	doublebuffer(pc),a0
	movem.l	(a0),d0-d1
	exg	d0,d1
	movem.l	d0-d1,(a0)
	
	lea	copperlist(pc),a0	
	move.l	#40*height,d2

	move.w	d1,bitplaneptr-copperlist+(8*1)+6(a0)
	swap	d1
	move.w	d1,bitplaneptr-copperlist+(8*1)+2(a0)
	swap	d1

	add.l	d2,d1
	move.w	d1,bitplaneptr-copperlist+(8*3)+6(a0)
	swap	d1
	move.w	d1,bitplaneptr-copperlist+(8*3)+2(a0)
	swap	d1

	add.l	d2,d1
	move.w	d1,bitplaneptr-copperlist+(8*0)+6(a0)
	swap	d1
	move.w	d1,bitplaneptr-copperlist+(8*0)+2(a0)
	swap	d1

	add.l	d2,d1
	move.w	d1,bitplaneptr-copperlist+(8*2)+6(a0)
	swap	d1
	move.w	d1,bitplaneptr-copperlist+(8*2)+2(a0)
	swap	d1

	add.l	d2,d1
	move.w	d1,bitplaneptr-copperlist+(8*4)+6(a0)
	swap	d1
	move.w	d1,bitplaneptr-copperlist+(8*4)+2(a0)
	swap	d1

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
	move.w	d2,d0
	move.w	d3,d1
	move.l	doublebuffer(pc),a0
	lea	40*height*3(a0),a0
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
	dc.w	$182,$000	 
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
	dc.w	$100,$5600	; 5 bitplanes dual playfield
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
beta	dc.w	300	; 
theta	dc.w	66	; 
phi1	dc.w	0	;
phi2	dc.w	160	;
phi3	dc.w	80	;

	;---- 3d datas
	
boxsize	equ	20
	
cube_vertex
	dc.w	8
	dc.w	-boxsize/2,	boxsize/2,	boxsize/2
	dc.w	boxsize/2,	boxsize/2,	boxsize/2
	dc.w	boxsize/2,	-boxsize/2,	boxsize/2
	dc.w	-boxsize/2,	-boxsize/2,	boxsize/2
	
	dc.w	-boxsize,	boxsize,	-boxsize
	dc.w	boxsize,	boxsize,	-boxsize
	dc.w	boxsize,	-boxsize,	-boxsize
	dc.w	-boxsize,	-boxsize,	-boxsize
	
cube_rotated
	ds.w	8*4

cube_reflected
	ds.w	8*4
	
cube_vectors
	dc.w	12		; line count
	
	dc.w	0,1,0,0,0,0,0,0	; word 0 => P1 
	dc.w	1,2,0,0,0,0,0,0	; word 1 => P2
	dc.w	2,3,0,0,0,0,0,0	; word 2 => P3 (cut point)
	dc.w	3,0,0,0,0,0,0,0	; word 3 => flags
				; word 4 => color index
	dc.w	5,4,0,0,0,0,0,0	; word 5 =>  
	dc.w	4,7,0,0,0,0,0,0	; word 6 => 
	dc.w	7,6,0,0,0,0,0,0	; word 7 => 
	dc.w	6,5,0,0,0,0,0,0 ;
				;
	dc.w	0,4,0,0,0,0,0,0 ; flags :
	dc.w	1,5,0,0,0,0,0,0	; %00 => vector not cutted front of cut plane
	dc.w	2,6,0,0,0,0,0,0	; %01 => vector is cutted
	dc.w	3,7,0,0,0,0,0,0	; %10 => vector not cutted behind cut plane	

cube_cutvectors
	ds.w	8*6		; cut vectors

cube_faces
	dc.w	6		; face count
	dc.w	4,%01,0,1,2,3,4
	dc.w	4,%01,0,5,6,7,8
	dc.w	4,%10,0,-5,-10,-1,9
	dc.w	4,%10,0,-3,11,-7,-12
	dc.w	4,%11,0,-9,-4,12,-6
	dc.w	4,%11,0,10,-8,-11,-2

	;---- mirror plane

planesize	EQU	40
	
mirror_vertices
	dc.w	4
	dc.w	-planesize, planesize, -40
	dc.w	planesize, planesize, -40
	dc.w	planesize, -planesize, -40
	dc.w	-planesize, -planesize, -40

mirror_rotated
	ds.w	4*4

mirror_vectors
	dc.w	4		; line count
	dc.w	0,1,%100,0	; p1,p2,color
	dc.w	1,2,%100,0
	dc.w	2,3,%100,0
	dc.w	3,0,%100,0

mirror_params
	ds.w	3
	ds.l	1
	ds.w	1

	;---- maths tables
		
sincos16
	incbin	sincos16
	
	;---- bitplanes
	
bitplane1
	ds.w	20*height*5
	
bitplane2
	ds.w	20*height*5	
