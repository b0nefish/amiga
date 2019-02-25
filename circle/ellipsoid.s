
	SECTION	ellipsoid,CODE_C

	include	/circle/startup.s

	;----

	lea	copperlist(pc),a0
	lea	bitmap(pc),a1
	move.l	a1,d0
	move.w	d0,bitplaneptr-copperlist+6(a0)
	swap	d0
	move.w	d0,bitplaneptr-copperlist+2(a0)

	;----

main	;move.w	#$f,$180(a6)

	lea	bitmap(pc),a0	
	lea	xplot+((320/2)*4)(pc),a1
	lea	yplot+((256/2)*4)(pc),a2

	move.w	#80/2,d0		
	move.w	#190/2,d1		
	jsr	ellipse(pc)		

	move.w	#24/2,d0	
	move.w	#90/2,d1	
	jsr	ellipse(pc)		

	;clr.w	$180(a6)

	;---- fill

	lea	bitmap(pc),a0
	lea	(40*256)-2(a0),a0
.wblt	btst.b	#6,2(a6)
	bne.b	.wblt
	move.l	a0,$50(a6)
	move.l	a0,$54(a6)
	move.w	#0,$64(a6)
	move.w	#0,$66(a6)	
	move.l	#(((%1001<<8)+%11110000)<<16)+%10010,$40(a6)
	move.w	#(256<<6)+20,$58(a6)	
	
	;----
	
vbsync	;move.l	$4(a6),d0
	;andi.l	#$1ff00,d0
	;cmpi.l	#$13700,d0
	;bne.b	vbsync

	;----

wlmb	btst.b	#6,$bfe001
	bne.b	wlmb

quit	rts

	;---- draw ellipsoid

ellipse	move.w	d1,d7		; 	
	mulu.w	d0,d0		; d0 = a²
	mulu.w	d1,d1		; d1 = b²
	subq.w	#1,d7		;
	ble.b	.next		;

.loop	move.l	d1,d2		;	
	move.w	d7,d3		;
	mulu.w	d3,d3		;
	sub.l	d3,d2		; 	
	mulu.w	d0,d2		; 
	divu.w	d1,d2		; d2 = ((b² - y²) * a²) / b²
	ble.b	.next		;
	ext.l	d2		;

	;---- sqrt32

	moveq	#31,d3		;
	moveq	#0,d4		;
	moveq	#0,d5		;

.log2	btst.l	d3,d2		;
	dbne	d3,.log2	; log2(a)
	lsr.w	#1,d3		;
	addx.w	d4,d3		;
	bset.l	d3,d5		; x0 = 2^(log2(a)/2)
	
	REPT	2		; 2 iterations
	move.l	d2,d3		;
	divu.w	d5,d3		;
	add.w	d3,d5		;
	lsr.w	#1,d5		;
	addx.w	d4,d5		; xi+1 = 1/2(xi + a/xi)	
	ENDR			;

	;---- plotter
	
	move.w	d7,d3		;
	lsl.w	#2,d3		;
	lsl.w	#2,d5		;
	movem.w	(a2,d3.w),d3/d4	;	
	movem.w	(a1,d5.w),d5/d6	;
	lea	(a0,d3.w),a3	;
	lea	(a0,d4.w),a4	;
	move.b	d5,d3		;
	move.b	d6,d4		;
	lsr.w	#3,d5		;
	lsr.w	#3,d6		;
	not.b	d3		;
	not.b	d4		;
	bset.b	d3,(a3,d5.w)	;
	bset.b	d4,(a3,d6.w)	;
	bset.b	d3,(a4,d5.w)	;
	bset.b	d4,(a4,d6.w)	;

.next	dbf	d7,.loop	;
.done	rts			;

	;---- copperlist
	
copperlist
	dc.w	$8e,$2c81
	dc.w	$90,$2cc1
	dc.w	$92,$38
	dc.w	$94,$d0
	dc.w	$100,$1200
	dc.w	$102,0
	dc.w	$104,0
	dc.w	$108,0
	dc.w	$10a,0
	dc.w	$180,0
	dc.w	$182,$fff

bitplaneptr
	dc.w	$e0,0
	dc.w	$e2,0

	dc.l	-2
	
	; ---- plot tables

x	SET 	-320/2
y	SET	-256/2

xplot	REPT	320
	dc.w	(320/2)+x, (320/2)-x
x	SET	x+1	
	ENDR	

yplot	REPT	256
	dc.w	((256/2)+y)*40,((256/2)-y)*40
y	SET	y+1	
	ENDR	

	;---- bitmaps
	
bitmap	ds.w	20*256*1
	
