
	SECTION	rollerscroll,CODE_C

	include	/rollerscroll/startup.s

	;---- precalc sin wave
	
wave	lea	sincos(pc),a0	;
	lea	sinwave1(pc),a1	;
	lea	sinwave2(pc),a2	;
	lea	bitplane1,a3	;
	lea	bitplane2,a4	;
	moveq	#0,d0		;
	moveq	#0,d6		;
	move.w	#320-1,d7	;
.loop	move.w	(a0,d0.w),d1	;
	muls.w	#50,d1		;
	add.l	d1,d1		;
	swap	d1		;
	addi.w	#150/2,d1	;
	mulu.w	#80,d1		;
	move.w	d6,d2		;
	lsr.w	#4,d2		;
	add.w	d2,d2		;
	add.w	d2,d1		;
	lea	(a3,d1.w),a5	;
	move.l	a5,(a1)		;
	lea	(a4,d1.w),a5	;
	move.l	a5,(a2)		;
	lea	4(a1),a1	;
	lea	4(a2),a2	;
	addq.w	#2,d0		;
	addq.w	#1,d6		;
	dbf	d7,.loop	;

	;---- main

main	move.w	#$5,$180(a6)

	;---- clear bitmap

	move.l	doublebuffer(pc),a0
	lea	40*50(a0),a0
	move.l	a0,$54(a6)
	move.l	#(%100000000)<<16,$40(a6)
	move.w	#0,$66(a6)	
	move.w	#((130*2)<<6)+20,$58(a6)

	;---- scrolltext

scroll	lea	text(pc),a0
	lea	chrcnt(pc),a1
	lea	scrlcnt(pc),a2
	move.b  (a2),d0
	andi.b   #7,d0
	bne.w   .shift
	
	;---- copy new char

.char	move.w	(a1),d0
        addq.w	#1,(a1)
        move.b  (a0,d0.w),d0
        bne.b   .copy
        clr.w	(a1)
        bra.b   .char

.copy	subi.b	#32,d0
	ext.w	d0
	add.w	d0,d0

	;---- copy font

	lea     charset(pc),a0
	lea     (a0,d0.w),a0
        lea     workbuffer(pc),a1
	lea	(42*4)+40(a1),a1
	move.l	#(%0000100100000000!$f0)<<16,d0
	moveq	#-1,d1
	move.l	#((120-2)<<16)!(42-2),d2

.wblt1	btst.b	#6,2(a6)
	bne.b	.wblt1

	movem.l	d0/d1,$40(a6)
        movem.l	a0/a1,$50(a6)
        move.l	d2,$64(a6)
        move.w	#(16*64)+1,$58(a6)

	;----

        lea     workbuffer+40(pc),a0
	move.w	d0,42*00(a0)
	move.w	d0,42*01(a0)
	move.w	d0,42*02(a0)
	move.w	d0,42*04(a0)
	move.w	d0,42*20(a0)
	move.w	d0,42*21(a0)
	move.w	d0,42*22(a0)
	move.w	d0,42*23(a0)
	move.w	d0,42*24(a0)
	move.w	d0,42*25(a0)
	move.w	d0,42*26(a0)
	move.w	d0,42*27(a0)
	move.w	d0,42*28(a0)
	move.w	d0,42*29(a0)
	move.w	d0,42*30(a0)
	move.w	d0,42*31(a0)
	move.w	d0,42*32(a0)
	move.w	d0,42*33(a0)
	move.w	d0,42*34(a0)
	move.w	d0,42*35(a0)
	move.w	d0,42*36(a0)
	move.w	d0,42*37(a0)
	move.w	d0,42*38(a0)
	move.w	d0,42*39(a0)
	move.w	d0,42*40(a0)
	move.w	d0,42*41(a0)
	move.w	d0,42*42(a0)
	move.w	d0,42*43(a0)
	move.w	d0,42*44(a0)
	move.w	d0,42*45(a0)
	move.w	d0,42*46(a0)
	move.w	d0,42*47(a0)

	;----- scroll 4px horizontally

k	EQU	3*16

.shift	lea     workbuffer(pc),a0
        lea     (k*40)-2(a0),a0
	move.l	a0,a1
	move.l  #((%0100100100000000!$f0)<<16)!%10,d0
	moveq	#-1,d1
	moveq	#0,d2

.wblt2	btst.b	#6,2(a6)
	bne.b	.wblt2

	movem.l	d0/d1,$40(a6)
	movem.l	a0/a1,$50(a6)
	move.l	d2,$64(a6)
	move.w	#(k*64)+21,$58(a6)

	;---- scroll 1px vertically

	lea     workbuffer(pc),a0
        lea     (k*42)-4(a0),a0		
	lea	42(a0),a1
	move.l  #((%0000100100000000!$f0)<<16)!%10,d0
	move.l	#-1,d1
	move.l	#((42-40)<<16)!(42-40),d2

.wblt3	btst.b	#6,2(a6)
	bne.b	.wblt3

	movem.l	d0/d1,$40(a6)
	movem.l	a0/a1,$50(a6)
	move.l	d2,$64(a6)
	move.w	#(k*64)+20,$58(a6)

	;---- roll

	lea     workbuffer(pc),a0
	move.l	a0,a1
        lea     (k*42)(a0),a0		

.wblt4	btst.b	#6,2(a6)
	bne.b	.wblt4

	move.l	20(a0),42+24(a1)
	move.l	20+4(a0),42+24+4(a1)
	move.l	20+8(a0),42+24+8(a1)
	move.l	0(a0),42+4(a1)
	move.l	0+4(a0),42+4+4(a1)
	move.l	0+8(a0),42+4+8(a1)

	;----

	addq.b  #2,(a2)

	;---- mirror

	lea	workbuffer(pc),a0
	move.l	a0,a1
	lea	(k*42)-42-42(a0),a0
	lea	(60*42)+4(a1),a1
	move.l  #(%0000100100000000!$f0)<<16,d0
	move.l	#-1,d1
	move.l	#((-80-(42-40))<<16)!(42-40)+42,d2

.wblt5	btst.b	#6,2(a6)
	bne.b	.wblt5

	movem.l	d0/d1,$40(a6)
	movem.l	a0/a1,$50(a6)
	move.l	d2,$64(a6)
	move.w	#(16*64)+20,$58(a6)	

	;----
	
	lea	workbuffer(pc),a0
	lea	59*42(a0),a1
	move.w	#16-1,d7
.loop
	REPT	40/4	
	move.l	(a0)+,(a1)+
	ENDR
	lea	2(a0),a0
	lea	42+2(a1),a1	
	dbf	d7,.loop

	;---- sinwave

sin	move.l	oho(pc),a0
	lea	workbuffer+(59*42),a2
	lea	$4c(a6),a4
	lea	$44(a6),a5

        move.w  #1,d0
        move.w	#(30*64)+1,d1
	move.w  #%0000100100000000!$f0,d2
	move.w  #%0000110100000000!($f0!$cc),d3
	move.w	#(320/16)-1,d7
		
.wblt	btst.b	#6,2(a6)
	bne.b	.wblt

	move.w	#0,$42(a6)
	move.w	#40-2,$62(a6)
        move.w	#42-2,$64(a6)
        move.w	#40-2,$66(a6)
        move.w	#%1000010000000000,$96(a6)

.loop	ror.w   #1,d0
	move.l	(a0)+,a3
	movem.l	a2/a3,$50(a6)
	move.w	d0,(a5)
	move.w	d2,$40(a6)
	move.w	d1,$58(a6)
	
	ror.w   #1,d0
	move.l	(a0)+,a1
	move.l	a1,a3
	movem.l	a1-a3,(a4)
	move.w	d0,(a5)
	move.w	d3,$40(a6)
	move.w	d1,$58(a6)
	
	ror.w   #1,d0
	move.l	(a0)+,a1
	move.l	a1,a3
	movem.l	a1-a3,(a4)
	move.w	d0,(a5)
	move.w	d1,$58(a6)
	
	ror.w   #1,d0
	move.l	(a0)+,a1
	move.l	a1,a3
	movem.l	a1-a3,(a4)
	move.w	d0,(a5)
	move.w	d1,$58(a6)

	ror.w   #1,d0
	move.l	(a0)+,a1
	move.l	a1,a3
	movem.l	a1-a3,(a4)
	move.w	d0,(a5)
	move.w	d1,$58(a6)

	ror.w   #1,d0
	move.l	(a0)+,a1
	move.l	a1,a3
	movem.l	a1-a3,(a4)
	move.w	d0,(a5)
	move.w	d1,$58(a6)

	ror.w   #1,d0
	move.l	(a0)+,a1
	move.l	a1,a3
	movem.l	a1-a3,(a4)
	move.w	d0,(a5)
	move.w	d1,$58(a6)

	ror.w   #1,d0
	move.l	(a0)+,a1
	move.l	a1,a3
	movem.l	a1-a3,(a4)
	move.w	d0,(a5)
	move.w	d1,$58(a6)

	ror.w   #1,d0
	move.l	(a0)+,a1
	move.l	a1,a3
	movem.l	a1-a3,(a4)
	move.w	d0,(a5)
	move.w	d1,$58(a6)

	ror.w   #1,d0
	move.l	(a0)+,a1
	move.l	a1,a3
	movem.l	a1-a3,(a4)
	move.w	d0,(a5)
	move.w	d1,$58(a6)

	ror.w   #1,d0
	move.l	(a0)+,a1
	move.l	a1,a3
	movem.l	a1-a3,(a4)
	move.w	d0,(a5)
	move.w	d1,$58(a6)

	ror.w   #1,d0
	move.l	(a0)+,a1
	move.l	a1,a3
	movem.l	a1-a3,(a4)
	move.w	d0,(a5)
	move.w	d1,$58(a6)

	ror.w   #1,d0
	move.l	(a0)+,a1
	move.l	a1,a3
	movem.l	a1-a3,(a4)
	move.w	d0,(a5)
	move.w	d1,$58(a6)

	ror.w   #1,d0
	move.l	(a0)+,a1
	move.l	a1,a3
	movem.l	a1-a3,(a4)
	move.w	d0,(a5)
	move.w	d1,$58(a6)

	ror.w   #1,d0
	move.l	(a0)+,a1
	move.l	a1,a3
	movem.l	a1-a3,(a4)
	move.w	d0,(a5)
	move.w	d1,$58(a6)

	ror.w   #1,d0
	move.l	(a0)+,a1
	move.l	a1,a3
	movem.l	a1-a3,(a4)
	move.w	d0,(a5)
	move.w	d1,$58(a6)

	lea	2(a2),a2
	dbf     d7,.loop

	move.w	#%10000000000,$96(a6)

	;---- screen swapping

	lea	doublebuffer(pc),a0
	movem.l	(a0),d0-d1
	exg	d0,d1
	movem.l	d0-d1,(a0)
	
	lea	copperlist(pc),a0
	;move.l	#workbuffer,d1
	move.w	d1,bitplaneptr-copperlist+6(a0)
	swap	d1
	move.w	d1,bitplaneptr-copperlist+2(a0)
	
	swap	d1
	addi.l	#40,d1

	move.w	d1,bitplaneptr-copperlist+6+8(a0)
	swap	d1
	move.w	d1,bitplaneptr-copperlist+2+8(a0)

	;----

	lea	oho(pc),a0
	movem.l	(a0),d0-d1
	exg	d0,d1
	movem.l	d0-d1,(a0)
	
	;----

	clr.w	$180(a6)

sync	move.l	4(a6),d0
	andi.l	#$1ff00,d0
	cmpi.l	#$13800,d0
	bne.b	sync
	
	;----
		
	btst.b	#6,$bfe001
	bne.w	main
	
	rts	

	;----

doublebuffer
	dc.l	bitplane1
	dc.l	bitplane2

oho
	dc.l	sinwave1
	dc.l	sinwave2
	
	;----

copperlist
	dc.w	$8e,$2c81
	dc.w	$90,$2cc1
	dc.w	$92,$38
	dc.w	$94,$d0
	dc.w	$100,$2200
	dc.w	$102,0
	dc.w	$104,0
	dc.w	$108,40
	dc.w	$10a,40

bitplaneptr
	dc.w	$e0,0
	dc.w	$e2,0
	dc.w	$e4,0
	dc.w	$e6,0
	;dc.w	$180,0
	dc.w	$182,$fff
	dc.w	$184,$666
	dc.w	$186,$fff

	dc.l	-2		; copper end

	;----

chrcnt	ds.w	1
scrlcnt	ds.b	1
text	dc.b	'THIS IS IMPOSSIBLE ! ROMANTIC OF EXALTY BACK IN TOWN AFTER 25 YEARS OF ABSENCE. -- ',0
        even
		
sinwave1
	ds.l	320
	dc.b	'sebo'

sinwave2
	ds.l	320
	dc.b	'sebo'
	
	;---- tables

sincos	incbin	/rollerscroll/sincos16
	
	;---- datas
	
charset	ds.b	120
	incbin	/rollerscroll/charset
	
	;---- bitmaps

workbuffer
	ds.w	21*256
	
bitplane1
	ds.w	20*256*2

bitplane2
	ds.w	20*256*2
