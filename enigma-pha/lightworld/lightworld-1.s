
	SECTION	lightworld,CODE_C

	include	/lightworld/startup.s

xview		EQU	352/2
yview		EQU	200/2
zproj		EQU	-256	; focal length			
sqrsize		EQU	500
zhorizon	EQU	6000

	;----  make chessboard

makeboard
	lea	board_vertex(pc),a0
	lea	board_vectors(pc),a1
	move.w	#zhorizon/2,d0
	move.w	#-zhorizon/2,d1
	move.w	d1,d2
	moveq	#1,d6
	move.w	#((zhorizon/sqrsize)/2)-1,d7

.loop1	move.w	d1,2(a0)
	move.w	d1,6(a0)
	move.w	d0,10(a0)
	move.w	d0,14(a0)
	move.w	d2,0(a0)
	move.w	d2,12(a0)
	addi.w	#sqrsize,d2	
	move.w	d2,4(a0)
	move.w	d2,8(a0)
	addi.w	#sqrsize,d2
		
	move.l	d6,(a1)+
	swap	d6
	move.w	d6,d5
	addq.w	#2,d6	
	move.l	d6,(a1)+
	swap	d6
	addq.w	#2,d6	
	move.l	d6,(a1)+	
	move.w	d6,(a1)+
	move.w	d5,(a1)+
	addq.w	#2,d6
	swap	d6
	addq.w	#2,d6	
	swap	d6

	lea	16(a0),a0
	dbf	d7,.loop1

	;----

	move.w	#zhorizon/2,d0
	move.w	#-zhorizon/2,d1
	move.w	d1,d2
	move.w	#((zhorizon/sqrsize)/2)-1,d7

.loop2	move.w	d1,0(a0)
	move.w	d0,4(a0)
	move.w	d0,8(a0)
	move.w	d1,12(a0)
	move.w	d2,2(a0)
	move.w	d2,6(a0)
	addi.w	#sqrsize,d2	
	move.w	d2,10(a0)
	move.w	d2,14(a0)
	addi.w	#sqrsize,d2
		
	move.l	d6,(a1)+
	swap	d6
	move.w	d6,d5
	addq.w	#2,d6	
	move.l	d6,(a1)+
	swap	d6
	addq.w	#2,d6	
	move.l	d6,(a1)+	
	move.w	d6,(a1)+
	move.w	d5,(a1)+
	addq.w	#2,d6
	swap	d6
	addq.w	#2,d6	
	swap	d6
	
	lea	16(a0),a0
	dbf	d7,.loop2

	;----

mainloop
	
	;---- clear

.wait	btst	#6,2(a6)
	bne.b	.wait
	
	move.l	bitplane(pc),$54(a6)
	move.l	#(%100000000)<<16,$40(a6)
	clr.w	$66(a6)
	move.w	#(200<<6)+(352/16),$58(a6)

	;---- rotate
	
	lea	board_vertex(pc),a0
	lea	board_rotated(pc),a1
	lea	sincos16(pc),a2
	lea	90*2(a2),a3
	move.w	zscroll(pc),d6
	move.w	#(((zhorizon/sqrsize)/2)*8)-1,d7

	move.w	xobs(pc),d1
	swap	d1
	move.w	zobs(pc),d1	; d1 = B [xb | zb]

rotate	move.l	(a0)+,d0	; d0 = A [xa | za]
	add.w	d6,d0		; z scroll
	sub.l	d1,d0		; d0 = BA [xa-xb | za-zb]   
	move.w	theta(pc),d3
	add.w	d3,d3
	move.w	(a2,d3.w),d2	; d2 = sin(theta)
	move.w	(a3,d3.w),d3	; d3 = cos(theta)
	move.w	d2,d4
	move.w	d3,d5
	muls.w	d0,d2		; d2 = BAz * sin(theta)
	muls.w	d0,d3		; d3 = BAz * cos(theta)
	swap	d0
	muls.w	d0,d4		; d4 = BAx * sin(theta)
	muls.w	d0,d5		; d5 = BAx * cos(theta)
	add.l	d3,d4
	sub.l	d2,d5
	add.l	d4,d4
	add.l	d5,d5
	swap	d4
	swap	d5
	move.w	d5,d0
	swap	d0
	move.w	d4,d0
	add.l	d1,d0		; d0 = OA [BAx'+xb | BAz'+zb]
	move.l	d0,(a1)+
	dbf	d7,rotate

	;----

.wait	btst	#6,2(a6)
	bne.b	.wait
	
	move.w	#44,$60(a6)		; bltcmod
	move.w	#44,$66(a6)		; bltdmod
	move.l	#$ffff8000,$72(a6)	; bltbdat + bltadat
	move.l	#$ffffffff,$44(a6)	; bltafwm + bltalwm

	;----

	move.l	bitplane(pc),a0
	lea	cpuclipping(pc),a2
	lea	board_rotated(pc),a5
	lea	board_vectors(pc),a4
	lea	debug(pc),a3
	move.w	#(((zhorizon/sqrsize)/2)*8)-1,d7
	;move	#3,d7
	
board_loop
	move.w	d7,d2
	add.w	d2,d2
	add.w	d2,d2
	move.w	0(a4,d2.w),d1
	move.w	2(a4,d2.w),d2
	add.w	d1,d1
	add.w	d1,d1
	add.w	d2,d2
	add.w	d2,d2
	move.l	(a5,d1.w),d0	; d0 = OA [xa | za]
	move.l	(a5,d2.w),d1	; d1 = OB [xb | zb]
			
	;---- z-clipping

	cmp.w	d0,d1
	bge.b	zclip
	exg	d0,d1
zclip	move.w	zobs(pc),d2
	cmp.w	d2,d1
	ble.w	out
	cmp.w	d2,d0
	bge.b	projection
	move.l	d1,d3
	sub.l	d0,d3		; d3 = dx.16 dz.16
	sub.w	d0,d2
	swap	d3
	muls.w	d3,d2
	swap	d3
	divs.w	d3,d2
	move.w	zobs(pc),d0
	swap	d0
	add.w	d2,d0		; d0 = x1 + dx(zproj-z1) / dz
	swap	d0

	;---- 3d -> 2d projection

projection
	move.w	xobs(pc),d2
	swap	d2
	move.w	zobs(pc),d2
	addi.w	#zproj,d2
	sub.l	d2,d0		; d0 = PA [xa-xp | za-zp]
	sub.l	d2,d1		; d1 = PB [xb-xp | zb-zp]

	;---- X projection
 
	move.w	d0,d3
	move.w	d1,d4
	swap	d0
	swap	d1
	ext.l	d0
	ext.l	d1
	asl.l	#8,d0		; PAx * (zobs-zproj)
	asl.l	#8,d1		; PBx * (zobs-zproj)
	divs.w	d3,d0		
	divs.w	d4,d1		
	move.w	#xview,d2
	add.w	d2,d0		; d0 = x1' = xview + PAx(zobs-zproj)/PAz
	add.w	d2,d1		; d1 = x2' = xview + PBx(zobs-zproj)/PBz

	;---- Y projection
	
	move.w	yobs(pc),d5	; d5 = dy	
	ext.l	d5
	asl.l	#8,d5		; d5 = PAy * (zobs-zproj)
	move.l	d5,d6		; d6 = PBy * (zobs-zproj)
	divs.w	d3,d5				
	divs.w	d4,d6
	move.w	#yview,d2
	add.w	d2,d5		; d2 = y1' = yview + PAy(zobs-zproj)/PAz
	add.w	d2,d6		; d5 = y2' = yview + PBy(zobs-zproj)/PBz

	;---- merge XY

	swap	d0
	swap	d1
	move.w	d5,d0
	move.w	d6,d1

;---------------------------------------------
; clipping
;---------------------------------------------
; d0 = [x1.16,y1.16]
; d1 = [x2.16,y2.16]
; a2 = cpu clipping buffer
;---------------------------------------------
; the line is processed as a downward vector
; where y2 > y1. If clipping occur on right edge
; the new vertex is passed in d4.
;---------------------------------------------
; alter d0-d4
;--------------------------------------------- 	

clipleft	equ	0
clipright	equ	351
cliptop		equ	120
clipbottom	equ	199
	
	;cmp.w	d0,d1
	;beq.w	out		; dy=0 ? out	
	
	;---- test if vector is outside
	
	cmp.w	d0,d1
	bge.b	.a
	exg	d0,d1		; switch verticaly
.a	cmpi.w	#clipbottom,d0  ; y1 > clipbottom ?
	bgt.w	out
	;cmp.w	d0,d1
	;beq.b	.i		; dy = 0 ?
	;cmpi.w	#cliptop,d1
	;bge.b	.c
	
	;----
	
.i	;swap	d0		; vector is verticaly outside
	;swap	d1		; check if vector hit right border
	
	;cmp.w	d0,d1
	;bge.b	.b
	;exg	d0,d1		; switch horizontaly			
.b	;cmpi.w	#clipright,d0
	;bge.w	out
	;cmpi.w	#clipright,d1
	;blt.w	out
	;not.b	cliptop(a2)	; hidden vector hit right border
	
	;bra.w	out
	
	;----

.c	swap	d0
	swap	d1
	
	cmp.w	d0,d1
	bge.b	.d
	exg	d0,d1		; switch horizontaly
.d	cmpi.w	#clipleft,d1
	blt.w	out
	cmpi.w	#clipright,d0
	bgt.w	out
	
	;---- test left window border
	
left	cmpi.w	#clipleft,d0
	bge.b	right
	move.l	d0,d2
	move.l	d1,d3
	sub.l	d0,d3	
	swap	d3		; d3 = dx.16 dy.16
	subi.w	#clipleft,d2	
	neg.w	d2		; d2 = clipleft-x1
	muls.w	d3,d2
	swap	d3
	divs.w	d3,d2		; d2 = dy(clipleft-x1) / dx
	swap	d2
	add.l	d2,d0		; d0 = y1 + dy(clipleft-x1) / dx
	move.w	#clipleft,d0
	
	;---- test right window border
	
right	;cmpi.w	#clipright,d0
	;beq.b	.iio
	cmpi.w	#clipright,d1
	ble.b	vertical_clipping
	move.l	d1,d2
	move.l	d0,d1
	sub.l	d0,d2	
	swap	d2			; d2 = dx.16 dy.16
	subi.w	#clipright,d1	
	neg.w	d1			; d1 = clipright-x1
	muls.w	d2,d1
	swap	d2
	divs.w	d2,d1			; d1 = dy(clipright-x1) / dx
	swap	d1
	add.l	d0,d1			; d1 = y1 + dy(clipright-x1) / dx
	move.w	#clipright,d1
	
.iio	move.l	d1,d4
	swap	d4
	cmpi.w	#cliptop,d4
	bge.b	.e
	move.w	#cliptop,d4
.e	cmpi.w	#clipbottom,d4
	bgt.b	vertical_clipping
	not.b	(a2,d4.w)

vertical_clipping
	swap	d0
	swap	d1
	
	;movem.l	d0-d1,(a3)
	;lea	8(a3),a3
	
	cmp.w	d0,d1
	;beq.w	out		; dy=0 ? out
	bge.b	top
	exg	d0,d1		; switch verticaly
	
	;---- test top window border
	
top	cmpi.w	#cliptop,d0
	bge.b	bottom
	cmpi.w	#cliptop,d1
	ble.w	out
	move.l	d0,d2
	move.l	d1,d3
	sub.l	d0,d3			
	swap	d3			; d3 = dy.16 dx.16
	subi.w	#cliptop,d2	
	neg.w	d2			; d2 = cliptop-y1
	muls.w	d3,d2
	swap	d3
	divs.w	d3,d2			; d2 = dx(cliptop-y1) / dy
	swap	d2
	add.l	d2,d0			; d0 = x1 + dx(cliptop-y1) / dy
	move.w	#cliptop,d0

bottom	cmpi.w	#clipbottom,d1
	ble.b	draw1px
	cmpi.w	#clipbottom,d0
	bgt.w	out
	move.l	d1,d2
	move.l	d0,d1
	sub.l	d0,d2			
	swap	d2			; d2 = dy.16 dx.16
	subi.w	#clipbottom,d1	
	neg.w	d1			; d1 = clipbottom-y1
	muls.w	d2,d1
	swap	d2
	divs.w	d2,d1			; d1 = dx(clipbottom-y1) / dy
	swap	d1
	add.l	d0,d1			; d1 = x1 + dx(clipbottom-y1) / dy
	move.w	#clipbottom,d1

	;----

draw1px	move.w	d1,d3
	move.l	d1,d2
	swap	d2
	move.w	d0,d1
	swap	d0
	;movem.w	d0-d3,(a3)
	;lea	8(a3),a3
	;dbf	d7,board_loop

	moveq	#0,d5
.dy	sub.w	d1,d3
	beq.b	out
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
	mulu.w	#44,d1
	add.w	d4,d1
	lea	(a0,d1.w),a1
	andi.w	#$f,d0
	add.w	d0,d0
	add.w	d2,d2		; d2 = 2pdelta
.wblt	btst	#6,2(a6)
	bne.b	.wblt
	move.w	d2,$62(a6)	; bltbmod
	sub.w	d3,d2		; 2pdelta - gdelta	
	bpl.b	.aptl
	addq.b	#8,d5
.aptl	move.w	d2,$52(a6)	; bltaptl
	sub.w	d3,d2		; 2pdelta - 2gdelta
	move.w	d2,$64(a6)			; bltamod
	move.w	bltcon0(pc,d0.w),$40(a6)	; bltcon0
	move.w	bltcon1(pc,d5.w),$42(a6)	; bltcon1
	move.l	a1,$48(a6)	; bltcpt
	move.l	a1,$54(a6)	; bltdpt
	lsl.w	#6,d3
	addq.w	#2,d3
	move.w	d3,$58(a6)	; bltsize

out	dbf	d7,board_loop
	bra.b	filling

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

	;----

.wait1	btst	#6,2(a6)
	bne.b	.wait1

filling	lea	44-1(a0),a1
	move.w	#200-2,d7
	moveq	#1,d0
	swap	d0
.loop	tst.b	(a2)
	beq.b	.false
	swap	d0
	clr.b	(a2)
.false	eor.b	d0,(a1)
	lea	44(a1),a1
	lea	1(a2),a2
	dbf	d7,.loop

.wait	btst	#6,2(a6)
	bne.b	.wait

	lea	(44*200)-2(a0),a0
	move.l	a0,$50(a6)
	move.l	a0,$54(a6)
	clr.l	$64(a6)
	move.l	#((%1001<<8)+%11110000)<<16+%10010),$40(a6)
	move.w	#((200/2)<<6)+22,$58(a6)
	
	;---- draw rasters

rastersfield
	lea	raster(pc),a0
	lea	pal180(pc),a1
	lea	pal182(pc),a2
	move.l	#zhorizon,d2
	move.w	#14-1,d7

rasterloop
	move.w	yobs(pc),d0
	move.w	d2,d1
	subi.w	#zproj,d1
	ext.l	d0
	asl.l	#8,d0
	divs.w	d1,d0			
	addi.w	#(278-yview),d0
	bmi.b	done
	cmpi.w	#255,d0
	bge.b	done
	lsl.w	#8,d0
	addq.b	#1,d0
	swap	d0
	move.w	#$fffe,d0
	move.l	d0,(a0)+
	move.w	#$0180,d0
	swap	d0
	move.w	(a1)+,d0
	move.l	d0,(a0)+
	move.w	#$0182,d0
	swap	d0
	move.w	(a2)+,d0
	move.l	d0,(a0)+
	
	subi.w	#zhorizon/14,d2
	dbf	d7,rasterloop

done	;move.l	#$ffddfffe,(a0)+
	;move.l	#$0001fffe,(a0)+
	;move.l	#$01800000,(a0)+
	;move.l	#-2,(a0)

	;----
	
	lea	bitplane(pc),a0
	lea	bitplaneptr(pc),a1
	
	movem.l	(a0),d0/d1
	exg	d0,d1
	movem.l	d0/d1,(a0)

	move.w	d1,6(a1)
	swap	d1
	move.w	d1,2(a1)

	;---- waitvbl
	
wait	move.l	$4(a6),d0
	andi.l	#$1ff00,d0
	cmpi.l	#$13700,d0
	bne.b	wait
	
	;---- keyboard

	lea	keystate(pc),a0
	move.b	$bfed01,d0
	btst	#3,d0
	beq.b	updateobserver
	move.b	$bfec01,d0
	move.b	d0,d1
	andi.b	#1,d0
	ror.b	#1,d1
	not.b	d1
	andi.b	#$7f,d1
	ext.w	d0
	ext.w	d1
	add.w	d1,d1
	move.w	d0,(a0,d1.w)
	bset	#6,$bfee01
	bclr	#6,$bfee01

	;----

updateobserver
	move.w	$4c*2(a0),d0
	add.w	d0,yobs
	move.w	$4d*2(a0),d0
	move.w	yobs(pc),d1
	sub.w	d0,d1
	cmpi.w	#yview,d1
	bge.b	.plus
	move.w	#yview,d1
.plus	move.w	d1,yobs

	move.w	$01*2(a0),d0
	add.w	d0,zobs
	move.w	$02*2(a0),d0
	sub.w	d0,zobs

	move.w	$10*2(a0),d0
	add.w	d0,xobs
	move.w	$11*2(a0),d0
	sub.w	d0,xobs

	move.w	$4f*2(a0),d0
	bne.b	.add
	move.w	$4e*2(a0),d0
	neg.w	d0
.add	move.w	theta(pc),d1
	add.w	d1,d0
	bpl.b	.max
	clr.w	d0
.max	cmpi.w	#360,d0
	blt.b	.save
	clr.w	d0
.save	move.w	d0,theta

	;----

scroll_chessboard
	lea	zscroll(pc),a0
	addi.w	#16,(a0)
	cmpi.w	#sqrsize*2,(a0)
	ble.b	.ok
	subi.w	#sqrsize*2,(a0)
.ok
	;----
	
	btst	#6,$bfe001
	bne.w	mainloop	
	
	rts

	;----

keystate
	dcb.w	128

xobs	dc.w	$109;0
yobs	dc.w	$e8;yview	; yobs >= yview
zobs	dc.w	$ffab
theta	dc.w	$9d
phi	dc.w	0
zscroll	dc.w	0

cpuclipping
	ds.b	256

	;----

pal180	dc.w	$100
	dc.w	$200
	dc.w	$300
	dc.w	$400
	dc.w	$500
	dc.w	$600
	dc.w	$700
	dc.w	$800
	dc.w	$900
	dc.w	$a00
	dc.w	$b00
	dc.w	$c00
	dc.w	$d00
	dc.w	$e00

pal182	dc.w	$001
	dc.w	$002
	dc.w	$003
	dc.w	$004
	dc.w	$005
	dc.w	$006
	dc.w	$007
	dc.w	$008
	dc.w	$009
	dc.w	$00a
	dc.w	$00b
	dc.w	$00c
	dc.w	$00d
	dc.w	$00e

	;----

copperlist
	dc.w	$8e,$2c00+129
	dc.w	$90,$2c00+(352-(255-129)-1)
	dc.w	$92,$d0-(8*(22-1))
	dc.w	$94,$d0
	dc.w	$100,$0200
	dc.w	$102,0
	dc.w	$104,0
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

	dc.w	$180,$f
	;dc.w	$182,0

	dc.w	(68<<8)+1,$fffe
	dc.w	$100,$1200
	dc.w	$180,$000

raster	ds.l	3*14

	dc.w	$ffdd,$fffe
		
	dc.w	((268-255)<<8)+1,$fffe
	dc.w	$100,$0200
	dc.w	$180,$f
	
	dc.l	-2

	;----

board_vertex
	ds.l	((zhorizon/sqrsize)/2)*4
	ds.l	((zhorizon/sqrsize)/2)*4
	dc.b	'sebo'

board_vectors
	ds.l	((zhorizon/sqrsize)/2)*4
	ds.l	((zhorizon/sqrsize)/2)*4
	dc.b	'sebo'

board_rotated
	ds.l	((zhorizon/sqrsize)/2)*4
	ds.l	((zhorizon/sqrsize)/2)*4		
	dc.b	'sebo'

sincos16
	incbin	sincos16

bitplane
	dc.l	bitplane1,bitplane2

debug	ds.l	100

bitplane1
	ds.b	44*256

bitplane2
	ds.b	44*256
	
