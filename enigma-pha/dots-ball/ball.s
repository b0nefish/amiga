
	SECTION	dotsphere,CODE_C

	include	startup.s

radius		equ	70
thetastep	equ	9
phistep		equ	9
dots		equ	(360/thetastep)*(180/phistep)

	;----

tables	lea	mulstable,a0
	move.b	#-127,d0
	move.w	#256-1,d7
.loop1	move.b	#0,d1
	move.w	#256-1,d6
.loop2	move.b	d0,d2
	move.b	d1,d3
	ext.w	d2
	ext.w	d3
	muls.w	d3,d2
	asr.l	#7,d2
	move.b	d2,(a0)+
	addq.b	#1,d1
	dbf	d6,.loop2
	addq.b	#1,d0
	dbf	d7,.loop1

	;----

	lea	screenoffset,a0
	move.w	#(320/2)/8,d0
	move.w	#200-1,d7
.loop3	move.w	d0,(a0)+
	addi.w	#40,d0
	dbf	d7,.loop3
	
	;----
	
sphere	lea	ball(pc),a0	;
	lea	sincos16,a1	; sin table
	lea	90*2(a1),a2	; cos table
	
	move.w	#180+5,d0	; phi
	move.w	#(180/phistep)-1,d7

.loop1	move.w	d0,d1		;
	add.w	d1,d1		;
	move.w	(a1,d1.w),d2	;
	muls.w	#radius,d2	;
	add.l	d2,d2		;
	swap	d2		; d2 = rho*sin(phi)
	move.w	(a2,d1.w),d1	;
	muls.w	#radius,d1	;
	add.l	d1,d1		;
	swap	d1		; d1 = rho*cos(phi)
	lsl.w	#8,d1		;	

	move.w	#5,d3		; theta
	move.w	#(360/thetastep)-1,d6

.loop2	move.w	d3,d4		;
	add.w	d4,d4		;
	move.w	(a2,d4.w),d5	;
	muls.w	d2,d5		; d5 = rho*sin(phi)*cos(theta)
	add.l	d5,d5		;
	swap	d5		;
	lsl.w	#8,d5		;
	move.w	(a1,d4.w),d4	;
	muls.w	d2,d4		; d4 = rho*sin(phi)*sin(theta)
	add.l	d4,d4		;
	swap	d4		;
	lsl.w	#8,d4		;	
	move.w	d5,(a0)+	; x
	move.w	d4,(a0)+	; y
	move.w	d1,(a0)+	; z

	addi.w	#thetastep,d3	; theta step
	dbf	d6,.loop2	;
	addi.w	#phistep,d0	; phi step
	dbf	d7,.loop1	;
	
	;----
	
mainloop
	;move.w	#$f00,$180(a6)
	
	move.l	triplebuffer+4(pc),$54(a6)
	move.l	#(%100000000)<<16,$40(a6)
	clr.w	$66(a6)
	move.w	#(200<<6)+(320/16),$58(a6)
	
	;----
	
matrix	lea	smcplotterloop(pc),a0
	lea	sincos16,a1
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
	muls.w	(sin,_beta.w),d2
	add.l	d2,d2
	swap	d2			; d2 = sin(alpha) * sin(beta)

	move.w	(cos,_alpha.w),d3
	muls.w	(sin,_theta.w),d3
	add.l	d3,d3
	swap	d3			; d3 = cos(alpha) * sin(theta)

	move.w	(cos,_alpha.w),d4
	muls.w	(cos,_theta.w),d4
	add.l	d4,d4
	swap	d4			; d4 = cos(alpha) * cos(theta)
	
matrix_z_component
	move.w	d2,d0
	muls.w	(cos,_theta.w),d0
	add.l	d0,d0
	swap	d0
	sub.w	d3,d0
	neg.w	d0
	lsr.w	#8,d0
	move.b	d0,7(a0)
	
	move.w	d4,d0
	muls.w	(sin,_beta.w),d0
	add.l	d0,d0
	swap	d0
	move.w	(sin,_alpha.w),d1
	muls.w	(sin,_theta.w),d1
	add.l	d1,d1
	swap	d1
	add.w	d1,d0
	neg.w	d0
	lsr.w	#8,d0
	move.b	d0,11(a0)

	move.w	(cos,_beta.w),d0
	muls.w	(cos,_theta.w),d0
	add.l	d0,d0
	swap	d0
	lsr.w	#8,d0
	move.b	d0,15(a0)

matrix_x_component
	move.w	d2,d0
	muls.w	(sin,_theta.w),d0
	add.l	d0,d0
	swap	d0
	add.w	d4,d0
	lsr.w	#8,d0
	move.b	d0,21(a0)
	
	move.w	(sin,_alpha.w),d0
	muls.w	(cos,_theta.w),d0
	add.l	d0,d0
	swap	d0
	move.w	(sin,_beta.w),d1
	muls.w	d3,d1
	add.l	d1,d1
	swap	d1
	sub.w	d1,d0
	neg.w	d0
	lsr.w	#8,d0
	move.b	d0,25(a0)
	
	move.w	(cos,_beta.w),d0
	muls.w	(sin,_theta.w),d0
	add.l	d0,d0
	swap	d0
	neg.w	d0
	lsr.w	#8,d0
	move.b	d0,29(a0)

matrix_y_component
	move.w	(sin,_alpha.w),d0
	muls.w	(cos,_beta.w),d0
	add.l	d0,d0
	swap	d0
	lsr.w	#8,d0
	move.b	d0,33(a0)
	
	move.w	(cos,_alpha.w),d0
	muls.w	(cos,_beta.w),d0
	add.l	d0,d0
	swap	d0
	lsr.w	#8,d0
	move.b	d0,37(a0)
	
	move.w	(sin,_beta.w),d0
	lsr.w	#8,d0
	move.b	d0,41(a0)

	;----

	lea	ball(pc),a0
	move.l	triplebuffer(pc),a1
	lea	mulstable+(256*127),a2
	lea	screenoffset+(200/2*2),a3
	move.w	dotscount(pc),d7
	subq.w	#1,d7

smcplotterloop
	movem.w	(a0)+,d0-d2	; d0 = x, d1 = y, d2 = z
	
	move.b	0(a2,d0.w),d3	;
	add.b	0(a2,d1.w),d3	;
	add.b	0(a2,d2.w),d3	; d3 = Pz'''
	blt.b	.hide
	
	move.b	0(a2,d0.w),d4	;
	add.b	0(a2,d1.w),d4	;
	add.b	0(a2,d2.w),d4	; d4 = Px'''
	
	move.b	0(a2,d0.w),d5	;
	add.b	0(a2,d1.w),d5	;
	add.b	0(a2,d2.w),d5	; d5 = Py'''
	
	move.b	d4,d0		;
	asr.b	#3,d4		;
	ext.w	d4		;
	ext.w	d5		;
	add.w	d5,d5		;
	add.w	(a3,d5.w),d4	;
	not.b	d0		;
	bset.b	d0,(a1,d4.w)	;
	
.hide	dbf	d7,smcplotterloop

	;----
	
	movem.w	alpha(pc),d0-d2
	addq.w	#1,d0
	addq.w	#2,d1
	addq.w	#1,d2
clipalpha
	cmpi.w	#360,d0
	blt.b	clipbeta
	moveq	#0,d0
clipbeta
	cmpi.w	#360,d1
	blt.b	cliptheta
	moveq	#0,d1
cliptheta
	cmpi.w	#360,d2
	blt.b	clipdone
	moveq	#0,d2
clipdone
	movem.w	d0-d2,alpha
	
	;----

	lea	dotscount(pc),a0
	cmpi.w	#dots,(a0)
	bge.b	countdone
	addi.w	#360/thetastep,(a0)
countdone
	
	;----

	;move.w	#0,$180(a6)

wait	btst.b	#6,2(a6)
	bne.b	wait
	move.l	4(a6),d0
	andi.l	#$1ff00,d0
	cmp.l	#$13800,d0
	bne.b	wait
	
	;----

	lea	triplebuffer(pc),a0
	movem.l	(a0),d0-d2
	exg	d0,d2
	exg	d0,d1
	movem.l	d0-d2,(a0)
	
	lea	copperlist(pc),a0
	lea	sincos8,a1
	lea	jump(pc),a2
	addi.w	#4,(a2)
	cmpi.w	#360,(a2)
	blt.b	makejmp
	clr.w	(a2)
makejmp	move.w	(a2),d0
	add.w	d0,d0
	move.w	(a1,d0.w),d0
	bpl.b	abs
	neg.w	d0
abs	mulu	#60,d0
	lsr.w	#8,d0
	mulu	#40,d0
	ext.l	d0
	add.l	d0,d2
	
	move.w	d2,bplptr-copperlist+6(a0)
	swap	d2
	move.w	d2,bplptr-copperlist+2(a0)

	;----
	
	btst.b	#6,$bfe001
	bne.w	mainloop

	;----

	rts

copperlist
	dc.w	$8e,$6081
	dc.w	$90,$2cc1
	dc.w	$92,$38
	dc.w	$94,$d0
	dc.w	$100,$1200
	dc.w	$102,0
	dc.w	$108,0
	dc.w	$10a,0

bplptr	dc.w	$e0,0
	dc.w	$e2,0
	
	dc.w	$180,0
	dc.w	$182,$fff

	dc.w	$ffdd,$fffe
	dc.w	$0b01,$fffe
	dc.w	$180,$1
	dc.w	$0c01,$fffe
	dc.w	$180,$2
	dc.w	$0f01,$fffe
	dc.w	$180,$3
	dc.w	$1201,$fffe
	dc.w	$180,$4
	dc.w	$1701,$fffe
	dc.w	$180,$5
	dc.w	$1f01,$fffe
	dc.w	$180,$6
	dc.w	$2801,$fffe
	dc.w	$180,$7

	dc.l	-2

	;----
	
triplebuffer
	dc.l	bitplane1	; plotter buffer
	dc.l	bitplane2	; blitter buffer
	dc.l	bitplane3	; screen buffer
	
bitplane1
	ds.w	20*256
	
bitplane2
	ds.w	20*256
	
bitplane3
	ds.w	20*256
	
	;----
	
alpha	dc.w	0		; z rotate angle
beta	dc.w	0		; x rotate angle
theta	dc.w	0		; y rotate angle

	;----

jump	
	dc.w	0

dotscount
	dc.w	(360/thetastep)

ball
	ds.w	dots*3

	;----

sincos8
	incbin	sincos8
	
sincos16
	incbin	sincos16

mulstable
	ds.b	256*256

screenoffset
	ds.w	200
	
