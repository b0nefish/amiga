
	SECTION	tvbox,CODE_C

	include	startup.s

nstars	EQU	36

	;---- enigma tvbox remake

make_mulstable
	lea	mulstable,a0
	move.b	#-128,d0
	move.w	#256-1,d7
.uloop	move.b	#-128,d1
	move.w	#256-1,d6
.vloop	move.b	d0,d2		; -128 <= d2 <= +127
	move.b	d1,d3		; -128 <= d3 <= +127
	ext.w	d2
	ext.w	d3
	muls.w	d3,d2
	asr.l	#7,d2
	move.b	d2,(a0)+
	addq.b	#1,d1
	dbf	d6,.vloop
	addq.b	#1,d0
	dbf	d7,.uloop

	subq.b	#1,mulstable

	;----

make_vmuls
	lea	vmuls(pc),a0
	moveq	#0,d0
	move.w	#256-1,d7
.loop	move.w	d0,(a0)+
	addi.w	#40,d0
	dbf	d7,.loop
	
	;---- randomize starfield	

make_stars
	lea	stars1(pc),a1
	lea	stars2(pc),a2
	move.w	#nstars-1,d7

.loop	move.w	#64,d5		; y

	jsr	rnd(pc)
	move.w	d0,d4
	subi.w	#64,d4		; x
	
	jsr	rnd(pc)
	move.w	d0,d6
	subi.w	#64,d6		; z
		
	movem.w	d4-d6,(a1)
	neg.w	d5
	movem.w	d4-d6,(a2)
	lea	6(a1),a1
	lea	6(a2),a2
	dbf	d7,.loop

	;---- set scroll bitplane

	;lea	scrollbuffer,a0
	;lea	q(pc),a1
	;move.l	a0,d0
	;move.w	d0,6(a1)
	;swap	d0
	;move.w	d0,2(a1)

	;----
	
mainloop
	;move.w	#$f00,$180(a6)
	
	;---- clean bitmap
	
	move.l	triplebuffer+4(pc),$54(a6)
	move.l	#(%100000000)<<16,$40(a6)
	clr.w	$66(a6)
	move.w	#((256*3)<<6)+(320/16),$58(a6)

	;---- scroll routine

	lea	scrollbuffer,a0
	lea	scroll_control(pc),a1
	lea	scrollcount(pc),a2
	
	cmpi.w	#16*21,(a2)
	blt.b	.scroll
	clr.w	(a2)
	
.scroll	move.w	(a2),d0
	andi.w	#15,d0
	move.b	d0,d1
	lsl.b	#4,d1
	or.b	d1,d0
	not.b	d0
	move.w	d0,2(a1)	; hardware scroll
	move.w	(a2),d0
	lsr.w	#4,d0
	add.w	d0,d0
	lea	(a0,d0.w),a0	; charset copy pointer in a0
	move.l	a0,d0
	addq.l	#2,d0
	move.w	10(a1),d1	; old pointer
	swap	d1
	move.w	14(a1),d1
	move.w	d0,14(a1)	; new bitmap pointer
	swap	d0
	move.w	d0,10(a1)
	swap	d0
	move.w	scrollspeed(pc),d2
	add.w	d2,(a2)
	
	cmp.l	d0,d1		; check pointer update
	beq.w	.done		; copy a new font if updated
	
	lea	charset,a1
	lea	textcount(pc),a2
	lea	text(pc),a3	
.get	move.w	(a2),d0	
	move.b	(a3,d0.w),d0	; get char
	bne.b	.copy
	clr.w	(a2)
	move.b	(a3),d0
.copy	ext.w	d0
	move.w	d0,d1
	subi.w	#32,d0
	bpl.b	.ascii
	move.w	d1,scrollspeed	; update scroll speed
	addq.w	#1,(a2)		; fetch next char
	bra.b	.get
.ascii	add.w	d0,d0
	lea	(a1,d0.w),a1	; a1 = bitmap font ptr
	addq.w	#1,(a2)		; fetch next char

row	SET	0
	REPT	16
	move.w	(120*row)(a1),(84*row)(a0)	
	move.w	(120*row)(a1),(84*row)+42(a0)	
row	SET	row+1
	ENDR

.done	bra.w	matrix

scrollcount
	ds.w	1
	
scrollspeed
	dc.w	4

textcount
	ds.w	1

text	incbin	'text'
	
	;---- box rotations matrix
	
matrix	lea	rotate_box+18(pc),a0
	lea	sincos16,a1
	lea	90*2(a1),a2

	move.w	box_alpha(pc),d5
	add.w	d5,d5
	move.w	box_beta(pc),d6
	add.w	d6,d6
	move.w	box_theta(pc),d7
	add.w	d7,d7

sin	equr	a1
cos	equr	a2
_alpha	equr	d5
_beta	equr	d6
_theta	equr	d7

	move.w	(sin,_alpha.w),d3
	muls	(sin,_beta.w),d3	; d3 = sin(alpha)*sin(beta)
	add.l	d3,d3
	swap	d3

	move.w	(cos,_alpha.w),d4
	muls	(sin,_beta.w),d4
	add.l	d4,d4
	swap	d4			; d4 = cos(alpha)*sin(beta)
			
matrix_z_component
	move.w	(sin,_beta.w),d0
	neg.w	d0
	lsr.w	#8,d0
	move.b	d0,3(a0)
	
	move.w	(sin,_alpha.w),d0
	muls	(cos,_beta.w),d0
	add.l	d0,d0
	swap	d0
	lsr.w	#8,d0
	move.b	d0,7(a0)

	move.w	(cos,_beta.w),d0
	muls	(cos,_alpha.w),d0
	add.l	d0,d0
	swap	d0
	lsr.w	#8,d0
	move.b	d0,11(a0)

matrix_x_component
	move.w	(cos,_beta.w),d0
	muls	(cos,_theta.w),d0
	add.l	d0,d0
	swap	d0
	lsr.w	#8,d0
	move.b	d0,3+22(a0)
	
	move.w	d3,d0
	muls	(cos,_theta.w),d0
	add.l	d0,d0
	swap	d0
	move.w	(cos,_alpha.w),d1
	muls	(sin,_theta.w),d1
	add.l	d1,d1
	swap	d1
	sub.w	d1,d0
	lsr.w	#8,d0
	move.b	d0,7+22(a0)
	
	move.w	d4,d0
	muls	(cos,_theta.w),d0
	add.l	d0,d0
	swap	d0
	move.w	(sin,_alpha.w),d1
	muls	(sin,_theta.w),d1
	add.l	d1,d1
	swap	d1
	add.w	d1,d0
	lsr.w	#8,d0
	move.b	d0,11+22(a0)

matrix_y_component
	move.w	(cos,_beta.w),d0
	muls	(sin,_theta.w),d0
	add.l	d0,d0
	swap	d0
	lsr.w	#8,d0
	move.b	d0,3+44(a0)
	
	move.w	d3,d0
	muls	(sin,_theta.w),d0
	add.l	d0,d0
	swap	d0
	move.w	(cos,_alpha.w),d1
	muls	(cos,_theta.w),d1
	add.l	d1,d1
	swap	d1
	add.w	d1,d0
	lsr.w	#8,d0
	move.b	d0,7+44(a0)
	
	move.w	d4,d0
	muls	(sin,_theta.w),d0
	add.l	d0,d0
	swap	d0
	move.w	(sin,_alpha.w),d1
	muls	(cos,_theta.w),d1
	add.l	d1,d1
	swap	d1
	sub.w	d1,d0
	lsr.w	#8,d0
	move.b	d0,11+44(a0)
	
	;---- rotate tv box
	
	lea	box_vertex(pc),a0
	lea	box_rotated(pc),a1
	move.w	(a0)+,d7
	jsr	rotate_box(pc)

	;----

draw_tvbox
	lea	box_visible_faces(pc),a2
	lea	box_faces(pc),a3
	lea	box_vectors+2(pc),a4
	lea	box_rotated(pc),a5
	
	move.w	(a3)+,d7	; face count
	subq.w	#1,d7
		
	;---- polygon vector product
	
.loop1	move.w	2(a3),d5
	bpl.b	.a			
	neg.w	d5
.a	subq.w	#1,d5
	lsl.w	#2,d5				
	movem.w	(a4,d5.w),d4/d5
	lsl.w	#3,d4
	lsl.w	#3,d5
	tst.w	2(a3)
	bpl.b	.b
	exg	d4,d5	
.b	movem.w	(a5,d4.w),d0/d1
	sub.w	0(a5,d5.w),d0	; x1 - x2
	sub.w	2(a5,d5.w),d1	; y1 - y2

	move.w	4(a3),d5			
	bpl.b	.c
	neg.w	d5
.c	subq.w	#1,d5
	lsl.w	#2,d5				
	movem.w	(a4,d5.w),d4/d5
	lsl.w	#3,d4
	lsl.w	#3,d5
	tst.w	4(a3)
	bpl.b	.d
	exg	d4,d5
.d	movem.w	(a5,d4.w),d2/d3
	sub.w	0(a5,d5.w),d2	; x4 - x3
	sub.w	2(a5,d5.w),d3	; y4 - y3

	muls.w	d3,d0
	muls.w	d2,d1
	sub.l	d1,d0
	bmi.b	.skip
	
	;----
	
	move.l	a3,(a2)+	; save visible face ptr
	
	movem.l	d0-a5,-(sp)
	move.l	10(a3),a0
	jsr	(a0)		; call subcode
	movem.l	(sp)+,d0-a5
	
.skip	move.w	(a3),d0
	add.w	d0,d0
	lea	6(a3,d0.w),a3	; fetch next face ptr
	dbf	d7,.loop1	; next face
	
	;---- draw borders

.wblt	btst	#6,2(a6)
	bne.b	.wblt
	move.w	#40,$60(a6)	; blitter draw line preset
	move.w	#40,$66(a6)
	move.l	#$ffff8000,$72(a6)
	move.l	#$ffffffff,$44(a6)

	lea	box_visible_faces(pc),a2
	move.w	box_faces(pc),d7
	subq.w	#1,d7		; face count

.loop2	tst.l	(a2)
	beq.b	.done
	move.l	(a2),a3		; get face ptr
	clr.l	(a2)+		; clean ptr
	move.w	(a3)+,d6
	subq.w	#1,d6		; line count

.loop3	move.w	(a3)+,d0
	bpl.b	.plus
	neg.w	d0
.plus	subq.w	#1,d0
	lsl.w	#2,d0
	movem.w	(a4,d0.w),d0/d2
	lsl.w	#3,d0
	lsl.w	#3,d2
	movem.w	0(a5,d0.w),d0/d1
	movem.w	0(a5,d2.w),d2/d3
	move.l	#40*256*2,d4
	jsr	draw(pc)
	dbf	d6,.loop3	; next line	
	dbf	d7,.loop2	; next face

.done	

	;---- animate 3d objects

animate_box	
	lea	box_alpha(pc),a0
	movem.w	(a0),d0-d2
	move.w	#360,d3

	;addq.w	#1,d0
	;addq.w	#2,d1
	;addq.w	#1,d2
	
.clip1	cmp.w	d3,d0
	blt.b	.clip2
	sub.w	d3,d0

.clip2	cmp.w	d3,d1
	blt.b	.clip3
	sub.w	#360,d1

.clip3	cmp.w	d3,d2
	blt.b	.done
	sub.w	d3,d2

.done	movem.w	d0-d2,(a0)

	;----

animate_pyramid	
	lea	pmd_alpha(pc),a0
	movem.w	(a0),d0-d2
	move.w	#360,d3

	addq.w	#2,d0
	addq.w	#1,d1
	addq.w	#2,d2
	
.clip1	cmp.w	d3,d0
	blt.b	.clip2
	sub.w	d3,d0

.clip2	cmp.w	d3,d1
	blt.b	.clip3
	sub.w	#360,d1

.clip3	cmp.w	d3,d2
	blt.b	.done
	sub.w	d3,d2

.done	movem.w	d0-d2,(a0)

	;----

animate_logo91	
	lea	logo91_alpha(pc),a0
	move.w	(a0),d0
	move.w	#360,d1

	addq.w	#2,d0
	
.clip1	cmp.w	d1,d0
	blt.b	.done
	sub.w	d1,d0

.done	move.w	d0,(a0)

	;----

	;move.w	#0,$180(a6)

	;---- screen swap

	lea	triplebuffer(pc),a0
	lea	copperlist(pc),a1
	movem.l	(a0),d0-d2
	exg	d0,d2
	exg	d0,d1
	movem.l	d0-d2,(a0)
	move.w	d2,bitplaneptr-copperlist+6(a1)
	swap	d2
	move.w	d2,bitplaneptr-copperlist+2(a1)
	
	swap	d2
	addi.l	#40*256,d2
	move.w	d2,bitplaneptr-copperlist+8+6(a1)
	swap	d2
	move.w	d2,bitplaneptr-copperlist+8+2(a1)
	
	swap	d2
	addi.l	#40*256,d2
	move.w	d2,bitplaneptr-copperlist+8+8+6(a1)
	swap	d2
	move.w	d2,bitplaneptr-copperlist+8+8+2(a1)

	;----

waitvbl	btst	#6,$2(a6)
	bne.b	waitvbl
	move.l	$4(a6),d0
	andi.l	#$1ff00,d0
	cmpi.l	#312<<8,d0
	bne.b	waitvbl

	;----
	
	btst	#6,$bfe001
	bne.w	mainloop

	;----

quit	rts

	;---- rotate box

rotate_box
	lea	mulstable+(256*128)+128,a2	
	subq.w	#1,d7
	
.loop	movem.w	(a0)+,d0-d2	; d0 = Ax, d1 = Ay, d2 = Az	
	lsl.w	#8,d0
	lsl.w	#8,d1
	lsl.w	#8,d2
			
	move.b	0(a2,d0.w),d3
	move.b	0(a2,d1.w),d4
	move.b	0(a2,d2.w),d5	; d3 = Bz
	ext.w	d3
	ext.w	d4
	ext.w	d5
	add.w	d4,d3
	add.w	d5,d3
	
	move.b	0(a2,d0.w),d4
	move.b	0(a2,d1.w),d5
	move.b	0(a2,d2.w),d6	; d4 = Bx
	ext.w	d4
	ext.w	d5
	ext.w	d6
	add.w	d5,d4
	add.w	d6,d4
	
	move.b	0(a2,d0.w),d5
	move.b	0(a2,d1.w),d1
	move.b	0(a2,d2.w),d2	; d5 = By
	ext.w	d5
	ext.w	d1
	ext.w	d2
	add.w	d1,d5
	add.w	d2,d5
		
	;---- projection
	
	move.w	d3,d6
	addi.w	#512,d3		; PBz = Bz - Oz + Pz
	beq.b	.done
	moveq	#9,d0
	ext.l	d4
	ext.l	d5
	asl.l	d0,d4
	asl.l	d0,d5
	divs.w	d3,d4		; PBx * (Oz - Pz) / PBz
	divs.w	d3,d5		; PBy * (Oz - Pz) / PBz
	
	;----
	
.done	addi.w	#320/2,d4
	addi.w	#256/2,d5
	movem.w	d4-d6,(a1)
	lea	8(a1),a1
	dbf	d7,.loop
	rts

	;---- line draw

; d0.w = x1 
; d1.w = y1
; d2.w = x2
; d3.w = y2
; d4.w = plane offset
	
draw	moveq	#0,d5
	cmp.w	d1,d3		; set downward
	bge.b	.dy
	exg	d0,d2
	exg	d1,d3
.dy	sub.w	d1,d3		; dy
	sub.w	d0,d2		; dx
	bge.b	.delta
	neg.w	d2
	addq.b	#4,d5
.delta	cmp.w	d2,d3		; d2 = pdelta
	bge.b	.ptr		; d3 = gdelta
	exg	d2,d3
	addq.b	#2,d5
.ptr	move.l	triplebuffer(pc),a0
	lea	(a0,d4.w),a0
	move.w	d0,d4
	lsr.w	#3,d4
	mulu	#40,d1
	add.w	d4,d1
	lea	(a0,d1.w),a0
	andi.w	#$f,d0
	add.w	d0,d0
	add.w	d2,d2		; d2 = 2pdelta
.wblt	btst	#6,2(a6)
	bne.b	.wblt	
	move.w	d2,$62(a6)		
	sub.w	d3,d2		; d2 = 2pdelta - gdelta 			
	bpl.b	.aptl
	addq.b	#8,d5
.aptl	move.w	d2,$52(a6)		
	sub.w	d3,d2		; d2 = 2pdelta - 2gdelta			
	move.w	d2,$64(a6)		
	move.w	bltcon0(pc,d0.w),$40(a6)
	move.w	bltcon1(pc,d5.w),$42(a6)
	move.l	a0,$48(a6)
	move.l	a0,$54(a6)
	lsl.w	#6,d3
	addi.w	#$42,d3		; gdelta + 1
	move.w	d3,$58(a6)
	rts

LF	SET	($f0&$cc)+($0f&$aa)

bltcon0	dc.w	$0b00+LF, $1b00+LF, $2b00+LF, $3b00+LF
	dc.w	$4b00+LF, $5b00+LF, $6b00+LF, $7b00+LF
	dc.w	$8b00+LF, $9b00+LF, $ab00+LF, $bb00+LF
	dc.w	$cb00+LF, $db00+LF, $eb00+LF, $fb00+LF

bltcon1	dc.w	(%000<<2)+%0000001	; #6
	dc.w	(%100<<2)+%0000001	; #7
	dc.w	(%010<<2)+%0000001	; #5
	dc.w	(%101<<2)+%0000001	; #4

	dc.w	(%000<<2)+%1000001	; #6
	dc.w	(%100<<2)+%1000001	; #7
	dc.w	(%010<<2)+%1000001	; #5
	dc.w	(%101<<2)+%1000001	; #4

	;---- random generator

rnd	lea	seed(pc),a0
	move.l	#$41c64e6d,d1	; a
	move.l	(a0),d0		; Xn	
	move.w	d1,d2
	mulu	d0,d2
	move.l	d1,d3
	swap	d3
	mulu	d0,d3
	swap	d3
	clr.w	d3
	add.l	d3,d2
	swap	d0
	mulu	d1,d0
	swap	d0
	clr.w	d0
	add.l	d2,d0
	addi.l	#12345,d0	; c
	move.l	d0,(a0)
	swap	d0
	andi.l	#$7fff,d0
	divu	#127,d0
	swap	d0		; d0 = (aXn + c) mod 127
	rts

seed	dc.w	0,14

	;---- effects mapped on faces

fx1	lea	pmd_zbox(pc),a0
	move.w	#boxsize,(a0)
	jsr	pmd(pc)
	rts

fx2	lea	pmd_zbox(pc),a0
	move.w	#-boxsize,(a0)
	jsr	pmd(pc)
	rts
	
fx3	include	starfield_1.s
fx4	include	starfield_2.s
fx5	include	pha.s
fx6	include	logo91.s
	
pmd	include	pyramid_1.s

	;----

copperlist
	dc.w	$8e,$2c81
	dc.w	$90,$3cc1
	dc.w	$92,$38
	dc.w	$94,$d0
	dc.w	$100,$3200
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
	
	dc.w	$180,0
	dc.w	$182,$555
	dc.w	$184,$fff
	dc.w	$186,$aaa
	dc.w	$188,$22f
	dc.w	$18a,$22f
	dc.w	$18c,$22f
	dc.w	$18e,$22f
	
	;---- scroll text
	
	dc.w	$ffdd,$fffe
	dc.w	$1001,$fffe
	dc.w	$92,$30
	dc.w	$94,$d0
	dc.w	$100,$0200
	
scroll_control
	dc.w	$102,0
	dc.w	$108,84-42
	dc.w	$e0,0
	dc.w	$e2,0
		
	dc.w	$1101,$fffe
	dc.w	$100,$1200
	dc.w	$182,$223
	dc.w	$1201,$fffe
	dc.w	$182,$335
	dc.w	$1301,$fffe
	dc.w	$182,$447
	dc.w	$1401,$fffe
	dc.w	$182,$559
	dc.w	$1501,$fffe
	dc.w	$182,$66b
	dc.w	$1601,$fffe
	dc.w	$182,$77d
	dc.w	$1701,$fffe
	dc.w	$182,$88e
	dc.w	$1801,$fffe
	dc.w	$182,$aae
	dc.w	$1901,$fffe
	dc.w	$182,$cce
	dc.w	$1a01,$fffe
	dc.w	$182,$eee
	dc.w	$1b01,$fffe
	dc.w	$182,$333
	dc.w	$1c01,$fffe
	dc.w	$182,$555
	dc.w	$1d01,$fffe
	dc.w	$182,$777
	dc.w	$1e01,$fffe
	dc.w	$182,$999
	dc.w	$1f01,$fffe
	dc.w	$182,$bbb
	dc.w	$2001,$fffe
	dc.w	$182,$ddd

	dc.w	$2101,$fffe
q	dc.w	$e0,0
	dc.w	$e2,0	
	dc.w	$182,$f00
	dc.w	$102,0
	dc.w	$100,$0200
	dc.l	-2		; copper end

triplebuffer
	dc.l	bitplane1	; plotter buffer
	dc.l	bitplane2	; blitter buffer
	dc.l	bitplane3	; screen buffer

	;--- angles
	
box_alpha	dc.w	360-90		; x rotate angle
box_beta	dc.w	0		; y rotate angle
box_theta	dc.w	0		; z rotate angle

pmd_alpha	dc.w	45		; x rotate angle
pmd_beta	dc.w	45		; y rotate angle
pmd_theta	dc.w	45		; z rotate angle

logo91_alpha	dc.w	45

	;---- 3d datas

boxsize	EQU	64

box_vertex
	dc.w	8
	dc.w	-boxsize,	boxsize,	boxsize
	dc.w	boxsize,	boxsize,	boxsize
	dc.w	boxsize,	-boxsize,	boxsize
	dc.w	-boxsize,	-boxsize,	boxsize
	
	dc.w	-boxsize,	boxsize,	-boxsize
	dc.w	boxsize,	boxsize,	-boxsize
	dc.w	boxsize,	-boxsize,	-boxsize
	dc.w	-boxsize,	-boxsize,	-boxsize
	
box_rotated
	ds.w	8*4
	
box_vectors
	dc.w	12	; vector count
	
	dc.w	0,1	; p1,p2
	dc.w	1,2
	dc.w	2,3
	dc.w	3,0
	
	dc.w	5,4
	dc.w	4,7
	dc.w	7,6
	dc.w	6,5
	
	dc.w	0,4
	dc.w	1,5
	dc.w	2,6
	dc.w	3,7	

box_faces
	dc.w	6
	
	dc.w	4,	1,2,3,4
	dc.l	fx1
	
	dc.w	4,	5,6,7,8
	dc.l	fx2
	
	dc.w	4,	-5,-10,-1,9
	dc.l	fx3
	
	dc.w	4,	-3,11,-7,-12
	dc.l	fx4

	dc.w	4,	-9,-4,12,-6
	dc.l	fx5
	
	dc.w	4,	10,-8,-11,-2
	dc.l	fx6

box_visible_faces
	ds.l	6

	;----

pmdsize	EQU	26

pmd_vertex
	dc.w	5
	dc.w	-pmdsize,	pmdsize,	pmdsize+10
	dc.w	pmdsize,	pmdsize,	pmdsize+10
	dc.w	pmdsize,	-pmdsize,	pmdsize+10
	dc.w	-pmdsize,	-pmdsize,	pmdsize+10
	dc.w	0,		0,		-pmdsize-10
	
pmd_rotated
	ds.w	5*4

pmd_boxrotated
	ds.w	5*4
	
pmd_vectors
	dc.w	8	; vector count
	
	dc.w	0,1	; p1,p2
	dc.w	1,2
	dc.w	2,3
	dc.w	3,0
	
	dc.w	0,4
	dc.w	1,4
	dc.w	2,4
	dc.w	3,4

pmd_faces
	dc.w	5
	
	dc.w	4,	4,3,2,1
	dc.w	3,	1,6,-5
	dc.w	3,	2,7,-6
	dc.w	3,	3,8,-7
	dc.w	3,	4,5,-8

pmd_zbox
	ds.w	1
	
	;---- maths tables

vmuls	ds.w	256
	dc.b	'sebo'

sincos16
	incbin	sincos16

mulstable
	ds.b	256*256
	dc.b	'sebo'
		
	;---- bitmaps
	
bitplane1
	ds.w	20*256*3
	
bitplane2
	ds.w	20*256*3
	
bitplane3
	ds.w	20*256*3

	;----

scrollbuffer
	ds.b	2*84*16
	dc.b	'sebo'
	
charset	incbin	fonts
