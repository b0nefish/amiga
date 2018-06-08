	
	lea	pmd_vertex(pc),a0
	lea	pmd_rotated(pc),a1
	lea	sincos16(pc),a3
	lea	90*2(a3),a4
	move.w	(a0)+,d7
	subq.w	#1,d7

_sin	EQUR	a3
_cos	EQUR	a4

.loop	movem.w	(a0)+,d0-d2

.z_rotate
	move.w	pmd_alpha(pc),d4
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
	move.w	pmd_beta(pc),d4
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
	move.w	pmd_theta(pc),d4
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

	move.w	pmd_zbox(pc),d2	
	bpl.b	.a
	neg.w	d0
	neg.w	d1
.a	movem.w	d0-d2,(a1)
	lea	6(a1),a1
	dbf	d7,.loop	; next vertex

	;---- rotated pyramid arround tvbox axis

	lea	pmd_rotated(pc),a0
	lea	pmd_boxrotated(pc),a1
	move.w	pmd_vertex(pc),d7
	jsr	rotate_box(pc)
	
	;---- draw pyramid
	
draw_pyramid

.wblt	btst	#6,2(a6)
	bne.b	.wblt

	move.w	#40,$60(a6)		; bltcmod
	move.w	#40,$66(a6)		; bltdmod
	move.l	#$ffff8000,$72(a6)	; bltbdat + bltadat
	move.l	#$ffffffff,$44(a6)	; bltafwm + bltalwm

	;----
	
	lea	pmd_boxrotated(pc),a3
	lea	pmd_vectors+2(pc),a4
	lea	pmd_faces(pc),a5
	
	move.w	(a5)+,d7	; face count
	subq.w	#1,d7

.loop1	move.w	(a5)+,d6	; line count
	subq.w	#1,d6
		
	;---- vector cross product
	
	move.w	0(a5),d5
	bpl.b	.a			
	neg.w	d5
.a	subq.w	#1,d5
	lsl.w	#2,d5				
	movem.w	(a4,d5.w),d4/d5
	lsl.w	#3,d4
	lsl.w	#3,d5
	tst.w	0(a5)
	bpl.b	.b
	exg	d4,d5	
.b	movem.w	(a3,d4.w),d0/d1
	sub.w	0(a3,d5.w),d0		; x1 - x2
	sub.w	2(a3,d5.w),d1		; y1 - y2

	move.w	2(a5),d5			
	bpl.b	.c
	neg.w	d5
.c	subq.w	#1,d5
	lsl.w	#2,d5				
	movem.w	(a4,d5.w),d4/d5
	lsl.w	#3,d4
	lsl.w	#3,d5
	tst.w	2(a5)
	bpl.b	.d
	exg	d4,d5
.d	movem.w	(a3,d4.w),d2/d3
	sub.w	0(a3,d5.w),d2		; x4 - x3
	sub.w	2(a3,d5.w),d3		; y4 - y3

	muls.w	d3,d0
	muls.w	d2,d1
	sub.l	d1,d0
	bmi.b	.skip

	move.l	a5,a2

.loop2	move.w	(a2)+,d0
	bpl.b	.e
	neg.w	d0
.e	subq.w	#1,d0
	lsl.w	#2,d0
	movem.w	(a4,d0.w),d0/d2
	lsl.w	#3,d0
	lsl.w	#3,d2
	movem.w	0(a3,d0.w),d0/d1
	movem.w	0(a3,d2.w),d2/d3
	move.w	#40*256,d4
	jsr	draw(pc)	
	dbf	d6,.loop2
	
.skip	move.w	-2(a5),d0
	add.w	d0,d0
	lea	(a5,d0.w),a5
	dbf	d7,.loop1

	rts
