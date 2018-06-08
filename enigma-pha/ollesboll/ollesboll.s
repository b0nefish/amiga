
	SECTION	ollesboll,CODE_C

	include	startup.s

radius		equ	70
thetastep	equ	36
phistep		equ	18
dots		equ	(360/thetastep)*(180/phistep)

	;----muls table

multab	lea	mulstable(pc),a0
	move.b	#-127,d0
	move.w	#256-1,d7
.uloop	move.b	#0,d1
	move.w	#256-1,d6
.vloop	move.b	d0,d2
	move.b	d1,d3
	ext.w	d2
	ext.w	d3
	muls	d3,d2
	asr.l	#7,d2
	move.b	d2,(a0)+
	addq.b	#1,d1
	dbf	d6,.vloop
	addq.b	#1,d0
	dbf	d7,.uloop

	;----

bplptrtab
	lea	bplptr(pc),a0
	moveq	#40,d0
	moveq	#0,d1
	move.w	#256-1,d7
.loop	move.l	d1,(a0)+
	add.l	d0,d1
	dbf	d7,.loop

	;---- compute sphere
	
calc_sphere
	lea	ball(pc),a0
	lea	sincos16(pc),a1	; sin table
	lea	90*2(a1),a2	; cos table
	moveq.w	#9,d0		; phi
	moveq.w	#(180/phistep)-1,d7
.phi_loop
	move.w	d0,d1
	add.w	d1,d1
	move.w	(a1,d1.w),d2
	muls	#radius,d2
	add.l	d2,d2
	swap	d2		; d2 = rho*sin(phi)
	move.w	(a2,d1.w),d1
	muls	#radius,d1
	add.l	d1,d1
	swap	d1		; d1 = rho*cos(phi)
	moveq.w	#0,d3		; theta
	moveq.w	#(360/thetastep)-1,d6
.theta_loop
	move.w	d3,d4
	add.w	d4,d4
	move.w	(a2,d4.w),d5
	muls	d2,d5		; d5 = rho*sin(phi)*cos(theta)
	add.l	d5,d5
	swap	d5
	move.w	(a1,d4.w),d4
	muls	d2,d4		; d4 = rho*sin(phi)*sin(theta)
	add.l	d4,d4
	swap	d4
	move.w	d5,(a0)+	; x.w
	move.w	d4,(a0)+	; y.w
	move.w	d1,(a0)+	; z.w
	addi.w	#thetastep,d3	; theta step
	dbf	d6,.theta_loop
	addi.w	#phistep,d0	; phi step
	dbf	d7,.phi_loop

	;---- extract lines
	
extract_lines

	lea	lines(pc),a0
	lea	linecount(pc),a1

longit	moveq	#0,d0
	moveq	#(180/phistep)-1,d7
.loop1	move.w	d0,d1
	moveq	#(360/thetastep)-1,d6
.loop2	move.w	d0,(a0)+
	addq.w	#1,d0
	move.w	d0,d2
	tst.w	d6
	bgt.b	.next
	move.w	d1,d2
.next	move.w	d2,(a0)+
	clr.l	(a0)+
	addq.w	#1,(a1)
	dbf	d6,.loop2
	dbf	d7,.loop1
	
latit	moveq	#0,d0
	moveq	#(360/thetastep)-1,d7
.loop1	move.w	d0,d1
	moveq	#(180/phistep)-2,d6
.loop2	move.w	d1,(a0)+
	addi.w	#(360/thetastep),d1
	move.w	d1,(a0)+
	clr.l	(a0)+
	addq.w	#1,(a1)
	dbf	d6,.loop2
	addq.w	#1,d0
	dbf	d7,.loop1

	;---- extract polygons
	
	lea	polygons(pc),a0
	lea	polycount(pc),a1

extract_body
	move.w	#0,d0
	move.w	#(360/thetastep),d1
	move.w	#(180/phistep)*(360/thetastep),d2
	move.w	#((180/phistep)*(360/thetastep))+((180/phistep)-1),d3
	move.w	#0,d4

	moveq	#(180/phistep)-2,d7
.loop1	moveq	#(360/thetastep)-1,d6
.loop2	tst.w	d6
	bgt.b	.skip
	move.w	#(180/phistep)*(360/thetastep),d3
	add.w	d4,d3
.skip	move.w	#4,(a0)+
	move.w	d0,(a0)+
	move.w	d3,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	addq.w	#1,d0
	addq.w	#1,d1
	addi.w	#(180/phistep)-1,d2
	addi.w	#(180/phistep)-1,d3
	addq.w	#1,(a1)
	dbf	d6,.loop2
	move.w	#(180/phistep)*(360/thetastep),d2
	move.w	#((180/phistep)*(360/thetastep))+((180/phistep)-1),d3
	addq.w	#1,d4
	add.w	d4,d2
	add.w	d4,d3	
	dbf	d7,.loop1

extract_poles
	move.w	#0,d0
	moveq	#2-1,d7
.loop1	moveq	#(360/thetastep)-1,d6
	move.w	#(360/thetastep),(a0)+
.loop2	move.w	d0,(a0)+
	addq.w	#1,d0
	dbf	d6,.loop2
	addq.w	#1,(a1)
	addi.w	#((180/phistep)-2)*(360/thetastep),d0
	dbf	d7,.loop1

	;----
	
	lea	ball(pc),a0
	move.w	#(dots*3)-1,d7
shiftloop
	move.w	(a0),d0
	lsl.w	#8,d0
	move.w	d0,(a0)+
	dbf	d7,shiftloop
	
	;---- main loop
	
mainloop
	
	;---- compute rotation matrix
	
matrix	lea	smcloop(pc),a0
	lea	sincos16(pc),a1
	lea	90*2(a1),a2

	move.w	alpha(pc),d5
	add.w	d5,d5
	move.w	beta(pc),d6
	add.w	d6,d6
	move.w	theta(pc),d7
	add.w	d7,d7

sin	equr	a1
cos	equr	a2
_alpha	equr	d5
_beta	equr	d6
_theta	equr	d7

	move.w	(sin,_alpha.w),d2
	muls	(sin,_beta.w),d2
	add.l	d2,d2
	swap	d2			; d2 = sin(alpha) * sin(beta)

	move.w	(cos,_alpha.w),d3
	muls	(sin,_theta.w),d3
	add.l	d3,d3
	swap	d3			; d3 = cos(alpha) * sin(theta)

	move.w	(cos,_alpha.w),d4
	muls	(cos,_theta.w),d4
	add.l	d4,d4
	swap	d4			; d4 = cos(alpha) * cos(theta)
	
matrix_z_component
	move.w	d2,d0
	muls	(cos,_theta.w),d0
	add.l	d0,d0
	swap	d0
	sub.w	d3,d0
	neg.w	d0
	lsr.w	#8,d0
	move.b	d0,7(a0)
	
	move.w	d4,d0
	muls	(sin,_beta.w),d0
	add.l	d0,d0
	swap	d0
	move.w	(sin,_alpha.w),d1
	muls	(sin,_theta.w),d1
	add.l	d1,d1
	swap	d1
	add.w	d1,d0
	neg.w	d0
	lsr.w	#8,d0
	move.b	d0,11(a0)

	move.w	(cos,_beta.w),d0
	muls	(cos,_theta.w),d0
	add.l	d0,d0
	swap	d0
	lsr.w	#8,d0
	move.b	d0,15(a0)

matrix_x_component
	move.w	d2,d0
	muls	(sin,_theta.w),d0
	add.l	d0,d0
	swap	d0
	add.w	d4,d0
	lsr.w	#8,d0
	move.b	d0,21(a0)
	
	move.w	(sin,_alpha.w),d0
	muls	(cos,_theta.w),d0
	add.l	d0,d0
	swap	d0
	move.w	(sin,_beta.w),d1
	muls	d3,d1
	add.l	d1,d1
	swap	d1
	sub.w	d1,d0
	neg.w	d0
	lsr.w	#8,d0
	move.b	d0,25(a0)
	
	move.w	(cos,_beta.w),d0
	muls	(sin,_theta.w),d0
	add.l	d0,d0
	swap	d0
	neg.w	d0
	lsr.w	#8,d0
	move.b	d0,29(a0)

matrix_y_component
	move.w	(sin,_alpha.w),d0
	muls	(cos,_beta.w),d0
	add.l	d0,d0
	swap	d0
	lsr.w	#8,d0
	move.b	d0,35(a0)
	
	move.w	(cos,_alpha.w),d0
	muls	(cos,_beta.w),d0
	add.l	d0,d0
	swap	d0
	lsr.w	#8,d0
	move.b	d0,39(a0)
	
	move.w	(sin,_beta.w),d0
	lsr.w	#8,d0
	move.b	d0,43(a0)

	;---- jump
	
jump_effect
	lea	sincos8(pc),a1
	lea	jump(pc),a2
	addq.w	#4,(a2)
	cmpi.w	#360,(a2)
	blt.b	.ok
	clr.w	(a2)
.ok	move.w	(a2),d0
	add.w	d0,d0
	move.w	(a1,d0.w),d0
	bmi.b	.abs
	neg.w	d0
.abs	muls.w	#90,d0
	asr.w	#8,d0
	addi.w	#(200/2)+20,d0
	move.w	d0,52(a0)
	
	;---- rotate sphere

rotate_sphere
	lea	ball(pc),a0
	lea	mulstable(pc),a1
	lea	(256*127)(a1),a1
	lea	ballrotated(pc),a2
	moveq.w	#dots-1,d7

smcloop	movem.w	(a0)+,d0-d2	; d0 = x, d1 = y, d2 = z
	move.b	0(a1,d0.w),d3
	add.b	0(a1,d1.w),d3
	add.b	0(a1,d2.w),d3	; d3 = Pz'''
	ext.w	d3
	move.b	0(a1,d0.w),d4
	add.b	0(a1,d1.w),d4
	add.b	0(a1,d2.w),d4	; d4 = Px'''
	ext.w	d4
	move.b	0(a1,d0.w),d5
	add.b	0(a1,d1.w),d5
	add.b	0(a1,d2.w),d5	; d5 = Py'''
	ext.w	d5
	addi.w	#320/2,d4
	addi.w	#200/2,d5
	movem.w	d3-d5,(a2)
	lea	8(a2),a2
	dbf	d7,smcloop

	;----

screen_swap
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
	
	;---- vbl sync

.wblt	btst	#6,2(a6)
	bne.b	.wblt

	;clr.w	$180(a6)
.wvbl	move.l	$4(a6),d0
	andi.l	#$1ff00,d0
	cmpi.l	#$13700,d0
	bne.b	.wvbl
	;move.w	#$f00,$180(a6)

	;--- clear buffer

clear_buffer
	move.l	doublebuffer(pc),a0
	lea	10(a0),a0
	move.l	a0,$54(a6)
	move.l	#(%100000000)<<16,$40(a6)
	move.w	#40-(10*2),$64(a6)
	move.w	#40-(10*2),$66(a6)	
	move.w	#((200*4)<<6)+10,$58(a6)	

	;--- polygons converter
	
convert_polygons
	lea	ballrotated(pc),a0
	lea	lines(pc),a1
	lea	polygons(pc),a2
	move.w	polycount(pc),d7
	subq.w	#1,d7

.loop	move.w	(a2)+,d6		; line count
	move.w	d6,d5
	add.w	d5,d5
	subq.w	#1,d6
	move.w	0(a2),d0
	move.w	2(a2),d1
	lsl.w	#3,d0
	lsl.w	#3,d1
	movem.w	0(a1,d0.w),d2-d3
	move.w	2(a1,d1.w),d4
	lsl.w	#3,d2
	lsl.w	#3,d3
	lsl.w	#3,d4
	move.w	0(a0,d2.w),d0
	add.w	0(a0,d3.w),d0
	add.w	0(a0,d4.w),d0
	cmpi.w	#38,d0
	bmi.b	.skip			; visibility
	move.l	a2,a3
	lsr.w	#4,d0			; colour index
.xor	move.w	(a3)+,d1
	lsl.w	#3,d1
	eor.w	d0,6(a1,d1.w)
	dbf	d6,.xor
.skip	lea	(a2,d5.w),a2
	dbf	d7,.loop

	;---- draw the ball

draw_object
	lea	lines(pc),a1
	lea	ballrotated(pc),a2
	move.w	linecount(pc),d7
	subq.w	#1,d7

.wblt	btst	#6,2(a6)
	bne.b	.wblt

	move.w	#40,$60(a6)		; bltcmod
	move.w	#40,$66(a6)		; bltdmod
	move.l	#$ffff8000,$72(a6)	; bltbdat + bltadat
	move.l	#$ffffffff,$44(a6)	; bltafwm + bltalwm

draw_loop
	movem.w	(a1)+,d4-d5
	move.l	(a1)+,d6
	beq.w	next_line
	clr.l	-4(a1)			; clear colour index
	lsl.w	#3,d4
	lsl.w	#3,d5
	movem.w	2(a2,d4.w),d0/d1
	movem.w	2(a2,d5.w),d2/d3

	;---- 1 pixel line draw
	
draw1px	moveq	#0,d5
	cmp.w	d1,d3
	beq.w	next_line
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
	lea	(a0,d4.w),a0
	lsl.w	#2,d1	
	add.l	bplptr(pc,d1.w),a0
	andi.w	#$f,d0
	add.w	d0,d0
	add.w	d2,d2		; d2 = 2pdelta
.wblt	btst	#6,2(a6)
	bne.b	.wblt
	move.w	d2,$62(a6)	; bltbmod
	sub.w	d3,d2		; 2pdelta - gdelta	
	bpl.b	.aptl
	addq.b	#8,d5
.aptl	move.w	d2,d1				; bltaptl
	sub.w	d3,d2				; 2pdelta - 2gdelta
	move.w	d2,$64(a6)			; bltamod
	move.w	bltcon0(pc,d0.w),d0		; bltcon0
	move.w	bltcon1(pc,d5.w),d5		; bltcon1
	move.l	a0,$48(a6)			; bltcpt
	move.l	a0,$54(a6)			; bltdpt
	lsl.w	#6,d3
	addq.w	#2,d3
	bra.w	draw_plane0
	
	;----

LF	equ	($f0&$55)+($0f&$aa)	; A XOR C

bltcon0	dc.w	$0b00+LF,$1b00+LF,$2b00+LF,$3b00+LF
	dc.w	$4b00+LF,$5b00+LF,$6b00+LF,$7b00+LF
	dc.w	$8b00+LF,$9b00+LF,$ab00+LF,$bb00+LF
	dc.w	$cb00+LF,$db00+LF,$eb00+LF,$fb00+LF

bltcon1	dc.w	(%000<<2)+%0000011	; #6
	dc.w	(%100<<2)+%0000011	; #7
	dc.w	(%010<<2)+%0000011	; #5
	dc.w	(%101<<2)+%0000011	; #4

	dc.w	(%000<<2)+%1000011	; #6
	dc.w	(%100<<2)+%1000011	; #7
	dc.w	(%010<<2)+%1000011	; #5
	dc.w	(%101<<2)+%1000011	; #4

bplptr	ds.l	256

	;----

draw_plane0
	ror.b	#1,d6
	bcc.b	draw_plane1
	move.w	d1,$52(a6)	
	movem.w	d0/d5,$40(a6)
	move.l	a0,$48(a6)
	move.l	a0,$54(a6)
	move.w	d3,$58(a6)	
	
draw_plane1
	lea	40*200(a0),a0
	ror.b	#1,d6
	bcc.b	draw_plane2
.wblt	btst	#6,2(a6)
	bne.b	.wblt
	move.w	d1,$52(a6)	
	movem.w	d0/d5,$40(a6)
	move.l	a0,$48(a6)
	move.l	a0,$54(a6)
	move.w	d3,$58(a6)	

draw_plane2
	lea	40*200(a0),a0
	ror.b	#1,d6
	bcc.b	draw_plane3
.wblt	btst	#6,2(a6)
	bne.b	.wblt
	move.w	d1,$52(a6)	
	movem.w	d0/d5,$40(a6)
	move.l	a0,$48(a6)
	move.l	a0,$54(a6)
	move.w	d3,$58(a6)	

draw_plane3
	lea	40*200(a0),a0
	ror.b	#1,d6
	bcc.b	next_line
.wblt	btst	#6,2(a6)
	bne.b	.wblt
	move.w	d1,$52(a6)	
	movem.w	d0/d5,$40(a6)
	move.l	a0,$48(a6)
	move.l	a0,$54(a6)
	move.w	d3,$58(a6)	
	
next_line

	dbf	d7,draw_loop

	;---- animate
	
moveangles
	movem.w	alpha(pc),d0-d2
	addq.w	#1,d0
	addq.w	#2,d1
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

	;---- fill

blitter_fill	
	move.l	doublebuffer(pc),a0
	lea	(40*200*4)-12(a0),a0
	
.wblt	btst	#6,2(a6)
	bne.b	.wblt
	
	move.l	a0,$50(a6)
	move.l	a0,$54(a6)
	move.w	#40-(10*2),$64(a6)
	move.w	#40-(10*2),$66(a6)	
	move.l	#(((%1001<<8)+%11110000)<<16)+%10010,$40(a6)
	move.w	#((200*4)<<6)+10,$58(a6)	
	
	;----
	
	btst	#6,$bfe001
	bne.w	mainloop
	
	;----
	
	rts
	
	;----

copperlist
	dc.w	$8e,$2c81
	dc.w	$90,$2cc1
	dc.w	$92,$38
	dc.w	$94,$d0
	dc.w	$100,$0200
	dc.w	$102,0
	dc.w	$108,0
	dc.w	$10a,0
	dc.w	$180,0
	dc.w	$6001,$fffe
	dc.w	$100,$4200
bitplaneptr
	dc.w	$e0,0
	dc.w	$e2,0
	dc.w	$e4,0
	dc.w	$e6,0
	dc.w	$e8,0
	dc.w	$ea,0
	dc.w	$ec,0
	dc.w	$ee,0	
	dc.w	$180,$000	
	dc.w	$182,$001
	dc.w	$184,$112
	dc.w	$186,$333
	dc.w	$188,$445
	dc.w	$18a,$666
	dc.w	$18c,$778
	dc.w	$18e,$999
	dc.w	$190,$aab
	dc.w	$192,$ddd
	dc.w	$194,$dde
	dc.w	$196,$eef
	dc.w	$198,$fff
	dc.w	$19a,$fff
	dc.w	$19c,$f00
	dc.w	$19e,$f00
raster	dc.w	$ffdd,$fffe
	dc.w	$0b01,$fffe
	dc.w	$180,$1
	dc.w	$0c01,$fffe
	dc.w	$180,$2
	dc.w	$0f01,$fffe
	dc.w	$180,$3
	dc.w	$1201,$fffe
	dc.w	$180,$4
	dc.w	$1701,$fffe
	dc.w	$100,$0200
	dc.w	$180,$5
	dc.w	$1f01,$fffe
	dc.w	$180,$6
	dc.w	$2801,$fffe
	dc.w	$180,$7
	dc.l	-2

	;----

doublebuffer
	dc.l	bitplane1
	dc.l	bitplane2
	
alpha	dc.w	0	; z rotate angle
beta	dc.w	0	; x rotate angle
theta	dc.w	0	; y rotate angle

jump	dc.w	0

ball	ds.w	dots*3
	dc.b	'sebo'
	
lines	ds.w	(360/thetastep)*(180/phistep)*4
	ds.w	(360/thetastep)*((180/phistep)-1)*4
	dc.b	'sebo'

linecount
	dc.w	0

polygons
	ds.w	(360/thetastep)*((180/phistep)-1)*5
	ds.w	(360/thetastep)+1
	ds.w	(360/thetastep)+1
	dc.b	'sebo'
	
polycount
	dc.w	0
	
ballrotated
	ds.w	dots*4	

sincos8
	incbin	sincos8
	
sincos16
	incbin	sincos16

mulstable
	ds.b	256*256

bitplane1
	ds.w	20*200*4
	
bitplane2
	ds.w	20*200*4
	
