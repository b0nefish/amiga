; 1 pixel sin scroller with kork effect
; original code idea by slayer/scoopex
; compile with devpac 2.15

	SECTION	rollerscroll,CODE_C

	include	/rollerscroll/startup.s

	;---- precalc sin wave
	
wave	lea	sincos(pc),a0	;
	lea	sinwave(pc),a1	;
	moveq	#0,d0		;
	move.w	#(320*3)-1,d7	;
.loop	move.w	(a0,d0.w),d1	;
	muls.w	#40,d1		;
	add.l	d1,d1		;
	swap	d1		;
	addi.w	#40,d1		;
	mulu.w	#80,d1		;
	move.w	d1,(a1)+	;
	addq.w	#2,d0		;
	cmpi.w	#360*2,d0	;
	ble.b	.next		;
	subi.w	#360*2,d0	;		
.next	dbf	d7,.loop	;

	;---- main

main	;move.w	#$5,$180(a6)

	;---- clear bitmap

	move.l	doublebuffer(pc),a0
	move.l	a0,$54(a6)
	move.l	#(%100000000)<<16,$40(a6)
	move.w	#0,$66(a6)	
	move.w	#((96*2)<<6)+20,$58(a6)

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
	lea	40(a1),a1
	moveq	#0,d0

	move.w	120*0(a0),42*0(a1)
	move.w	120*1(a0),42*1(a1)
	move.w	120*2(a0),42*2(a1)
	move.w	120*3(a0),42*3(a1)
	move.w	120*4(a0),42*4(a1)
	move.w	120*5(a0),42*5(a1)
	move.w	120*6(a0),42*6(a1)
	move.w	120*7(a0),42*7(a1)
	move.w	120*8(a0),42*8(a1)
	move.w	120*9(a0),42*9(a1)
	move.w	120*10(a0),42*10(a1)
	move.w	120*11(a0),42*11(a1)
	move.w	120*12(a0),42*12(a1)
	move.w	120*13(a0),42*13(a1)
	move.w	120*14(a0),42*14(a1)
	move.w	120*15(a0),42*15(a1)
	move.w	d0,42*16(a1)
	move.w	d0,42*17(a1)
	move.w	d0,42*18(a1)
	move.w	d0,42*19(a1)
	move.w	d0,42*20(a1)
	move.w	d0,42*21(a1)
	move.w	d0,42*22(a1)
	move.w	d0,42*23(a1)
	move.w	d0,42*24(a1)
	move.w	d0,42*25(a1)
	move.w	d0,42*26(a1)
	move.w	d0,42*27(a1)
	move.w	d0,42*28(a1)
	move.w	d0,42*29(a1)
	move.w	d0,42*30(a1)
	move.w	d0,42*31(a1)

	;----- scroll 4px horizontally

.shift	addq.b  #2,(a2)

	lea     workbuffer(pc),a0
        lea     (32*42)-2(a0),a0
	move.l	a0,a1
	move.l  #((%0100100100000000!$f0)<<16)!%10,d0
	moveq	#-1,d1
	moveq	#0,d2

.wblt2	btst.b	#6,2(a6)
	bne.b	.wblt2

	movem.l	d0/d1,$40(a6)
	movem.l	a0/a1,$50(a6)
	move.l	d2,$64(a6)
	move.w	#(32*64)+21,$58(a6)

	;---- scroll 1px vertically

	lea     workbuffer(pc),a0
        lea     (32*42)-2-2(a0),a0		
	lea	42(a0),a1
	move.l  #((%0000100100000000!$f0)<<16)!%10,d0
	move.l	#-1,d1
	move.l	#((42-40)<<16)!(42-40),d2

.wblt3	btst.b	#6,2(a6)
	bne.b	.wblt3

	movem.l	d0/d1,$40(a6)
	movem.l	a0/a1,$50(a6)
	move.l	d2,$64(a6)
	move.w	#(32*64)+20,$58(a6)

	;---- roll

	lea     workbuffer(pc),a0
	move.l	a0,a1
        lea     (32*42)(a0),a0		

.wblt4	btst.b	#6,2(a6)
	bne.b	.wblt4

	move.l	24(a0),42+24(a1)
	move.l	24+4(a0),42+24+4(a1)
	move.l	24+8(a0),42+24+8(a1)
	move.l	8(a0),42+8(a1)
	move.l	8+4(a0),42+8+4(a1)
	move.l	8+8(a0),42+8+8(a1)

	;---- mirror and interleave

	lea	workbuffer(pc),a0
	move.l	a0,a1
	lea	(32*42)(a0),a0
	lea	(61*42)(a1),a1
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
	lea	60*42(a0),a1
	move.w	#16-1,d7

.loop	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	lea	2(a0),a0
	lea	42+2(a1),a1	
	dbf	d7,.loop

	;---- sinwave

sin	lea	sinwave(pc),a0
	move.l	doublebuffer(pc),a1
	lea	workbuffer+(60*42),a3
	lea	$4c(a6),a5

	move.w	wavepos(pc),d0
	lea	(a0,d0.w),a0

	move.w	#(32*64)+1,d0
	move.w  #%0000100100000000!$f0,d1
	move.w  #%0000110100000000!($f0!$cc),d2
	move.w	#(320/16)-1,d7
		
.wblt	btst.b	#6,2(a6)
	bne.b	.wblt

	move.w	#0,$42(a6)
	move.w	#-1,$46(a6)
	move.w	#40-2,$62(a6)
        move.w	#42-2,$64(a6)
        move.w	#40-2,$66(a6)
        move.w	#%1000010000000000,$96(a6)

.loop	move.w	(a0)+,d3
	lea	(a1,d3.w),a4
	movem.l	a3/a4,$50(a6)
	move.w	#1<<15,$44(a6)
	move.w	d1,$40(a6)
	move.w	d0,$58(a6)
	
	move.w	(a0)+,d3
	lea	(a1,d3.w),a4
	move.l	a4,a2
	movem.l	a2-a4,(a5)
	move.w	#1<<14,$44(a6)
	move.w	d2,$40(a6)
	move.w	d0,$58(a6)
	
	move.w	(a0)+,d3
	lea	(a1,d3.w),a4
	move.l	a4,a2
	movem.l	a2-a4,(a5)
	move.w	#1<<13,$44(a6)
	move.w	d0,$58(a6)

	move.w	(a0)+,d3
	lea	(a1,d3.w),a4
	move.l	a4,a2
	movem.l	a2-a4,(a5)
	move.w	#1<<12,$44(a6)
	move.w	d0,$58(a6)

	move.w	(a0)+,d3
	lea	(a1,d3.w),a4
	move.l	a4,a2
	movem.l	a2-a4,(a5)
	move.w	#1<<11,$44(a6)
	move.w	d0,$58(a6)

	move.w	(a0)+,d3
	lea	(a1,d3.w),a4
	move.l	a4,a2
	movem.l	a2-a4,(a5)
	move.w	#1<<10,$44(a6)
	move.w	d0,$58(a6)

	move.w	(a0)+,d3
	lea	(a1,d3.w),a4
	move.l	a4,a2
	movem.l	a2-a4,(a5)
	move.w	#1<<9,$44(a6)
	move.w	d0,$58(a6)

	move.w	(a0)+,d3
	lea	(a1,d3.w),a4
	move.l	a4,a2
	movem.l	a2-a4,(a5)
	move.w	#1<<8,$44(a6)
	move.w	d0,$58(a6)

	move.w	(a0)+,d3
	lea	(a1,d3.w),a4
	move.l	a4,a2
	movem.l	a2-a4,(a5)
	move.w	#1<<7,$44(a6)
	move.w	d0,$58(a6)

	move.w	(a0)+,d3
	lea	(a1,d3.w),a4
	move.l	a4,a2
	movem.l	a2-a4,(a5)
	move.w	#1<<6,$44(a6)
	move.w	d0,$58(a6)

	move.w	(a0)+,d3
	lea	(a1,d3.w),a4
	move.l	a4,a2
	movem.l	a2-a4,(a5)
	move.w	#1<<5,$44(a6)
	move.w	d0,$58(a6)

	move.w	(a0)+,d3
	lea	(a1,d3.w),a4
	move.l	a4,a2
	movem.l	a2-a4,(a5)
	move.w	#1<<4,$44(a6)
	move.w	d0,$58(a6)

	move.w	(a0)+,d3
	lea	(a1,d3.w),a4
	move.l	a4,a2
	movem.l	a2-a4,(a5)
	move.w	#1<<3,$44(a6)
	move.w	d0,$58(a6)

	move.w	(a0)+,d3
	lea	(a1,d3.w),a4
	move.l	a4,a2
	movem.l	a2-a4,(a5)
	move.w	#1<<2,$44(a6)
	move.w	d0,$58(a6)

	move.w	(a0)+,d3
	lea	(a1,d3.w),a4
	move.l	a4,a2
	movem.l	a2-a4,(a5)
	move.w	#1<<1,$44(a6)
	move.w	d0,$58(a6)
	
	move.w	(a0)+,d3
	lea	(a1,d3.w),a4
	move.l	a4,a2
	movem.l	a2-a4,(a5)
	move.w	#1<<0,$44(a6)
	move.w	d0,$58(a6)

	lea	2(a1),a1
	lea	2(a3),a3
	dbf     d7,.loop

	move.w	#%10000000000,$96(a6)

	lea	wavepos(pc),a0
	addq.w	#2,(a0)
	cmpi.w	#360*2,(a0)
	ble.b	.done
	subi.w	#360*2,(a0)
.done

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

	;clr.w	$180(a6)

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
	
	;----

copperlist
	dc.w	$8e,$2c81
	dc.w	$90,$2cc1
	dc.w	$92,$38
	dc.w	$94,$d0
	dc.w	$100,$0200
	dc.w	$102,0
	dc.w	$104,0
	dc.w	$108,40
	dc.w	$10a,40

bitplaneptr
	dc.w	$e0,0
	dc.w	$e2,0
	dc.w	$e4,0
	dc.w	$e6,0
	dc.w	$180,0
	dc.w	$184,$208

y	SET	$4c
col1	SET	$f07
	REPT	15
	dc.w	(y<<8)!1,$fffe
	IFEQ	y-$4c
	dc.w	$100,$2200
	ENDC
	dc.w	$182,col1
	dc.w	$186,col1
y	SET	y+3
col1	SET	col1+$10
	ENDR

	REPT	2
	dc.w	(y<<8)!1,$fffe
	dc.w	$182,col1
	dc.w	$186,col1
y	SET	y+3
	ENDR
	
	REPT	15
	dc.w	(y<<8)!1,$fffe
	dc.w	$182,col1
	dc.w	$186,col1
y	SET	y+3
col1	SET	col1-$10
	ENDR

	dc.w	((y-2)<<8)!1,$fffe
	dc.w	$100,$0200

	dc.l	-2		; copper end

	;----

chrcnt	ds.w	1
scrlcnt	ds.b	1
text	dc.b	'NOTE THAT THIS IS SCROLLER IS A 1 PIXEL SINE SCROLLER '
	dc.b	'WITH KORK EFFECT.....    '
	dc.b	'TRY TO BEAT THIS SUCKER !!!                    '
	dc.b	0
        even

wavepos	ds.w	1		
sinwave	ds.w	320*3
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

