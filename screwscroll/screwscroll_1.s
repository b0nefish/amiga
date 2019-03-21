
	SECTION	screwscroll,CODE_C

	include	/screwscroll/startup.s

	;---- precalc rotation

prerotate
	lea	sincos(pc),a0	
	lea	90*2(a0),a1
	lea	scrollbpl(pc),a2
	lea	(16+8)*42(a2),a2
	lea	rotate(pc),a3
	
	move.w	#0,d0		; angle
	add.w	d0,d0		;
	move.w	#0,d1		; y
	move.w	#16,d2		; z
	move.w	#320-1,d7	;

.loop	move.w	(a0,d0.w),d3	; d3 = sin(beta)
	move.w	(a1,d0.w),d4	; d4 = cos(beta)
	move.w	d3,d5		;
	move.w	d4,d6		;

	muls.w	d1,d4		; d4 = y * cos(beta) * k
	muls.w	d2,d3		; d3 = z * sin(beta) * k
	muls.w	d2,d6		; d6 = z * cos(beta) * k
	muls.w	d1,d5		; d5 = y * sin(beta) * k
	add.l	d3,d4		;
	sub.l	d5,d6		;
	add.l	d4,d4		;
	add.l	d6,d6		;
	swap	d4		; d4 = y'
	swap	d6		; d6 = z'
	muls.w	#42,d4		;
	lea	(a2,d4.l),a4	;
	move.l	a4,(a3)+	;
	move.w	d6,(a3)+	;
	addq.w	#2,d0		; next angle
	dbf	d7,.loop	;
	
main	move.w	#$5,$180(a6)

	;---- clear bitmap

	move.l	doublebuffer(pc),a0
	move.l	a0,$54(a6)
	move.l	#(%100000000)<<16,$40(a6)
	move.w	#0,$66(a6)	
	move.w	#((256*2)<<6)+20,$58(a6)

	;---- scrolltext

scroll	lea	text(pc),a0
	lea	chrcnt(pc),a1
	lea	scrlcnt(pc),a2
	move.b  (a2),d0
	andi.b   #15,d0
	bne.b   .shift
	
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

	lea     charset(pc),a0
	lea     (a0,d0.w),a0
        lea     scrollbpl(pc),a1
	lea	((16+8)*42)+40(a1),a1
        move.l	#(%0000100100000000!$f0)<<16,d0
	moveq   #-1,d1
	move.l	#((120-2)<<16)!(42-2),d2

.wblt1	btst.b	#6,2(a6)
	bne.b	.wblt1

	movem.l	d0/d1,$40(a6)
        movem.l	a0/a1,$50(a6)
        move.l	d2,$64(a6)
        move.w	#(16*64)+1,$58(a6)

	;---- scroll bitmap

.shift	lea     scrollbpl(pc),a0
        lea     ((16+8+16)*42)-2(a0),a0
	move.l	a0,a1
	move.l  #((%0010100100000000!$f0)<<16)!%10,d0
        moveq   #-1,d1
	moveq	#0,d2

.wblt2	btst.b	#6,2(a6)
	bne.b	.wblt2

	movem.l	d0/d1,$40(a6)
	movem.l	a0/a1,$50(a6)
	move.l	d2,$64(a6)
	move.w	#(16*64)+21,$58(a6)
	
	addq.b  #2,(a2)

	;----

mirror	lea	scrollbpl(pc),a0
	lea     ((16+8)*42)(a0),a0
	lea	16*3*42(a0),a1
	move.w	#16-1,d7

.wblt	btst.b	#6,2(a6)
	bne.b	.wblt

.loop	REPT	40/4
	move.l	(a0)+,(a1)+
	ENDR
	lea	2(a0),a0
	lea	(-42*2)+2(a1),a1
	dbf	d7,.loop	

	;----

screw	move.l	doublebuffer(pc),a0
	lea	40*(256/2)(a0),a0
	lea	40*256(a0),a1
	lea	rotate(pc),a2
	;lea	sincos(pc),a5

	move.w	#(320/16)-1,d7
        move.l  #$00010001,d0
        move.w	#(16*64)+1,d1
	moveq	#0,d6
		
	bsr.w	wblt

	move.l  #(%0000110100000000!($f0!$cc))<<16,$40(a6)
	move.w	#40-2,$62(a6)
        move.w	#42-2,$64(a6)
        move.w	#40-2,$66(a6)

.loop2	move.w	#15,d5
         
.loop1
	
	;REPT	16

	move.l	(a2)+,a3
	lea	(a3,d6.w),a3
	lea	42*16*2(a3),a4
	ror.l   #1,d0

	move.w	(a2)+,d2
	bpl.b	.k	
	
	bsr.w	wblt
        move.l	a0,$4c(a6)
        move.l	a3,$50(a6)
        move.l	a0,$54(a6)
        move.l	d0,$44(a6)
        move.w	d1,$58(a6)
	bra.b	.ll

.k	move.l	a1,$4c(a6)
	move.l	a4,$50(a6)
	move.l	a1,$54(a6)
        move.l	d0,$44(a6)
        move.w	d1,$58(a6)

	;ENDR
.ll	dbf	d5,.loop1

.done	lea	2(a0),a0
	lea	2(a1),a1
	addq.w	#2,d6
        dbf     d7,.loop2

	;---- screen swapping

	lea	doublebuffer(pc),a0
	movem.l	(a0),d0-d1
	exg	d0,d1
	movem.l	d0-d1,(a0)
	
	lea	copperlist(pc),a0
	;move.l	#scrollbpl,d1
	move.w	d1,bitplaneptr-copperlist+6(a0)
	swap	d1
	move.w	d1,bitplaneptr-copperlist+2(a0)
	
	swap	d1
	addi.l	#40*256,d1

	move.w	d1,bitplaneptr-copperlist+6+8(a0)
	swap	d1
	move.w	d1,bitplaneptr-copperlist+2+8(a0)
	
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

wblt	btst.b	#6,2(a6)
	bne.b	wblt
	rts

	;----

doublebuffer
	dc.l	bitplane1	; screen buffer
	dc.l	bitplane2	; draw buffer
	
	;----

copperlist
	dc.w	$8e,$2c81
	dc.w	$90,$2cc1
	dc.w	$92,$38
	dc.w	$94,$d0
	dc.w	$100,$2200
	dc.w	$102,0
	dc.w	$104,0
	dc.w	$108,0
	dc.w	$10a,0

bitplaneptr
	dc.w	$e0,0
	dc.w	$e2,0
	dc.w	$e4,0
	dc.w	$e6,0
	;dc.w	$180,0
	dc.w	$182,$fff
	dc.w	$184,$444

	dc.w	$ac01,$fffe
	dc.w	$182,$444

	dc.w	$ad01,$fffe
	dc.w	$182,$666

	dc.w	$ae01,$fffe
	dc.w	$182,$bbb

	dc.w	$af01,$fffe
	dc.w	$182,$fff

	dc.w	$b001,$fffe
	dc.w	$182,$fff

	dc.w	$b101,$fffe
	dc.w	$182,$fff

	dc.w	$b201,$fffe
	dc.w	$182,$fff

	dc.w	$b301,$fffe
	dc.w	$182,$fff

	dc.w	$b401,$fffe
	dc.w	$182,$fff

	dc.w	$b501,$fffe
	dc.w	$182,$fff

	dc.w	$b601,$fffe
	dc.w	$182,$fff

	dc.w	$b701,$fffe
	dc.w	$182,$fff

	dc.w	$b801,$fffe
	dc.w	$182,$fff

	dc.w	$b901,$fffe
	dc.w	$182,$bbb

	dc.w	$ba01,$fffe
	dc.w	$182,$666

	dc.w	$bb01,$fffe
	dc.w	$182,$444

	dc.l	-2		; copper end

	;----

chrcnt	ds.w	1
scrlcnt	ds.b	1
text	dc.b	'THIS IS IMPOSSIBLE ! ROMANTIC OF EXALTY BACK IN TOWN AFTER 25 YEARS OF ABSENCE. -- ',0
        even
		
rotate
	ds.l	320
	ds.w	320
	dc.b	'sebo'

	;---- tables

sincos
	incbin	/screwscroll/sincos16
	
	;---- datas
	
charset
	incbin	/screwscroll/fonts
	
	;---- bitmaps

scrollbpl
	ds.w	21*256
	
bitplane1
	ds.w	20*256*2

bitplane2
	ds.w	20*256*2
