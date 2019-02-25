
	SECTION	circle,CODE_C

	include	/circle/startup.s

mainloop

	lea	copperlist(pc),a0
	lea	bitmap(pc),a1
	move.l	a1,d0
	move.w	d0,bitplaneptr-copperlist+6(a0)
	swap	d0
	move.w	d0,bitplaneptr-copperlist+2(a0)

	;----

	lea	bitmap(pc),a0	
	lea	xplot+((320/2)*4)(pc),a1
	lea	yplot+((256/2)*4)(pc),a2

	move.w	#90,d7		; rayon
	move.w	d7,d0		;
	beq.w	.done		;
	mulu.w	d0,d0		; d0 = r²
	subq.w	#1,d7		;

.loop	move.w	d7,d1		;
	mulu.w	d1,d1		; d1 = y²
	move.w	d0,d2		;
	sub.l	d1,d2		; x² = r² - y²
	ble.b	.next

	;---- sqrt

	moveq	#0,d4		;
	moveq	#0,d5		;
	moveq	#31,d6		;
.log2	btst.l	d6,d2		;
	dbne	d6,.log2	; log2(a)
	lsr.w	#1,d6		;
	addx.w	d5,d6		;
	bset.l	d6,d5		; x0 = 2^(log2(a)/2)
	
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
	move.b	d5,d1		;
	move.b	d6,d2		;
	lsr.w	#3,d5		;
	lsr.w	#3,d6		;
	not.b	d1		;
	not.b	d2		;
	bset.b	d1,(a3,d5.w)	;
	bset.b	d2,(a3,d6.w)	;
	bset.b	d1,(a4,d5.w)	;
	bset.b	d2,(a4,d6.w)	;

.next	dbf	d7,.loop	;

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
.done

	;----

lmb	btst.b	#6,$bfe001
	bne.b	lmb

	rts

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
	
