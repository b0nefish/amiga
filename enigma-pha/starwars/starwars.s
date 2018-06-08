
	SECTION	starwars,CODE_C

	include	startup.s

height	EQU	130	
row	EQU	6	
angle	EQU	70	 
yobs	EQU	-80	  
zobs	EQU	-yobs

	;---- precalc projection
	
preproj	lea	projection,a0	; precalc (n/z) with :
	move.w	#-100,d0	;
	move.w	#256-1,d7	; -128 <= n <= +127 
.loop1	move.w	#-128,d1	; -100 <= z <= +155
	move.w	#256-1,d6	;
.loop2	move.w	d0,d2		;
	move.w	d1,d3		;
	add.w	d2,d2		;
	add.w	d2,d2		;
	add.w	d3,d3		;
	ext.l	d3		;
	asl.l	#8,d3		;
	addi.w	#256,d2		;
	beq.b	.zero		;
	divs.w	d2,d3		;
.zero	move.w	d3,(a0)+	; 2n*256 / 4z+256
	addq.w	#1,d1		;
	dbf	d6,.loop2	;
	addq.w	#1,d0		;
	dbf	d7,.loop1	;

	;---- precalc x rotation
		
prerotate
	lea	sincos,a0	
	lea	90*2(a0),a1	
	lea	projection+((256*100)+128)*2,a2
	lea	rotate,a3	
	
	move.w	#angle,d0	; rotation angle
	add.w	d0,d0		;
	move.w	#yobs-(600/2),d1; y
	move.w	#zobs-0,d2	; z
	move.w	#600-1,d7	;
	
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

	asr.w	#1,d4		; -128 <= (y'/2) <= +127
	asr.w	#2,d6		; -100 <= (z'/4) <= +155
	ext.l	d4		;
	ext.l	d6		;

	move.l	d6,d5		;
	asl.l	#8,d5		;
	add.l	d5,d4		;
	add.l	d4,d4		;
	move.w	(a2,d4.l),d4	;
	addi.w	#24,d4		;
	
	move.w	d4,(a3)+	; y
	move.w	d6,(a3)+	; z
	
	addq.w	#1,d1		; y = y + 1
	dbf	d7,.loop	;

	;----
	
preshift
	lea	text(pc),a0
	lea	indent(pc),a1
	move.w	#((endtext-text)/16)-1,d7
	move.w	#'  ',d0

.loop1	moveq	#0,d2
	move.l	a0,a2
.loop2	move.w	(a2)+,d1
	cmp.w	d0,d1
	beq.b	.next
	addq.w	#2,d2
	cmp.b	d0,d1
	bne.b	.loop2
	subq.w	#1,d2
	bra.b	.loop2
.next	moveq	#0,d3
	mulu.w	#40,d2
	beq.b	.push
	move.l	#(512-10),d3
	sub.l	d2,d3
	lsr.l	#1,d3
.push	move.l	d3,(a1)+
	lea	16(a0),a0
	dbf	d7,.loop1

	;---- mainloop
		
mainloop

	;move.w	#$f00,$180(a6)

	;---- clean bitmap

.wblt	btst.b	#6,2(a6)
	bne.b	.wblt

	move.l	doublebuffer(pc),a0
	move.l	a0,$54(a6)
	move.l	#(%100000000)<<16,$40(a6)
	clr.w	$66(a6)
	move.w	#(height<<6)+32,$58(a6)

	;----
	
	move.w	scroll(pc),d0
	andi.w	#63,d0
	bne.w	draw

	;---- make scroll

vectorize
	lea	vectors(pc),a0	;
	lea	text(pc),a1	;
	lea	charset,a2	;
	lea	indent(pc),a3	;

	clr.w	(a0)+		;
	clr.w	count		;
		
.loop1	move.w	count(pc),d5	;
	move.w	d5,d6		;
	andi.w	#15,d5		; d5 = xpen
	lsr.w	#4,d6		; d6 = ypen
	cmpi.w	#row-1,d6	;
	bgt.w	draw		;

	move.w	scroll(pc),d0	;
	lsr.w	#6,d0		;
	lsl.w	#4,d0		;
	add.w	count(pc),d0	;

	move.b	(a1,d0.w),d0	; get ascii code
	bne.b	.ascii		; end of text ?
	clr.w	scroll		;
	clr.w	count		;
	bra.w	draw		;
.ascii	ext.w	d0		;
	subi.w	#32,d0		;
	beq.w	.next		;
	lsl.w	#2,d0		;
	
	;---- vectorize
	
	move.l	(a2,d0.w),a4	; get vector data pointer
	tst.w	2(a4)		; draw something ?
	beq.b	.next		; 

	move.w	(a4),d0		;
	mulu.w	#6,d0		;
	lea	6(a4,d0.w),a5	;
	
	move.w	scroll(pc),d4	;
	lsr.w	#6,d4		;
	add.w	d6,d4		;
	lsl.w	#2,d4		;
	
	mulu.w	#40,d5		; xpen * 40
	lsl.w	#6,d6		; ypen * 64
	add.l	(a3,d4.w),d5	;
	subi.l	#256-(30/2),d5	;
	subi.w	#(64*2)+32,d6	;

	move.w	2(a4),d7	; get line count
	subq.w	#1,d7		;

.loop2	movem.w	(a5)+,d0/d2
	mulu.w	#6,d0
	mulu.w	#6,d2
	movem.w	6(a4,d0.w),d0/d1
	movem.w	6(a4,d2.w),d2/d3		
	add.l	d5,d0		; x1 + xpen
	add.l	d5,d2		; x2 + xpen
	add.w	d6,d1		; y1 + ypen
	add.w	d6,d3		; y2 + ypen
	movem.w	d0-d3,(a0)	;
	lea	8(a0),a0	;
	addq.w	#1,vectors	;
	dbf	d7,.loop2	;

.next	addq.w	#1,count
	bra.w	.loop1

	;----

draw	move.l	doublebuffer(pc),a0
	lea	vectors,a1
	lea	rotate+((600/2)*4),a2
	lea	projection+((256*100)+128)*2,a3
	move.w	#512/2,d6
	move.w	(a1)+,d7
	subq.w	#1,d7
	bmi.w	fill

.wblt1	btst.b	#6,2(a6)
	bne.b	.wblt1
	
	move.w	#32*2,$60(a6)
	move.w	#32*2,$66(a6)
	move.l	#$ffff8000,$72(a6)
	move.l	#$ffffffff,$44(a6)

.loop	movem.w	(a1)+,d0-d3	;
	move.w	scroll(pc),d4	;
	andi.w	#63,d4		;
	sub.w	d4,d1		;
	sub.w	d4,d3		;
	asl.w	#2,d1		;
	asl.w	#2,d3		;
	movem.w	(a2,d1.w),d1/d4	; d1 = y1 ; d4 = z1
	movem.w	(a2,d3.w),d3/d5	; d3 = y2 ; d5 = z2
	asl.l	#8,d4		;
	asl.l	#8,d5		;
	asr.l	#1,d0		;
	asr.l	#1,d2		;
	add.l	d4,d0		;
	add.l	d5,d2		;
	add.l	d0,d0		;
	add.l	d2,d2		;
	move.w	(a3,d0.l),d0	;
	move.w	(a3,d2.l),d2	;
	add.w	d6,d0		;
	add.w	d6,d2		;
	
	;----
	
.line	moveq	#0,d5
	cmp.w	d1,d3
	beq.b	.done
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
.ptr	move.w	d0,d4
	lsr.w	#3,d4
	lsl.w	#6,d1
	add.w	d4,d1
	lea	(a0,d1.w),a4
	andi.w	#$f,d0
	add.w	d0,d0
	add.w	d2,d2		; d2 = 2pdelta
.wblt2	btst.b	#6,2(a6)
	bne.b	.wblt2
	move.w	d2,$62(a6)	; bltbmod
	sub.w	d3,d2		; 2pdelta - gdelta	
	bpl.b	.aptl
	addq.b	#8,d5
.aptl	move.w	d2,$52(a6)
	sub.w	d3,d2
	move.w	d2,$64(a6)
	move.w	.bltcon0(pc,d0.w),$40(a6)
	move.w	.bltcon1(pc,d5.w),$42(a6)
	move.l	a4,$48(a6)
	move.l	a4,$54(a6)
	lsl.w	#6,d3
	addq.w	#2,d3
	move.w	d3,$58(a6)

.done	dbf	d7,.loop	; next line
	bra.b	fill
	
	;----

LF	SET	($f0&$55)+($0f&$aa)	; A XOR C

.bltcon0	
	dc.w	$0b00+LF, $1b00+LF, $2b00+LF, $3b00+LF
	dc.w	$4b00+LF, $5b00+LF, $6b00+LF, $7b00+LF
	dc.w	$8b00+LF, $9b00+LF, $ab00+LF, $bb00+LF
	dc.w	$cb00+LF, $db00+LF, $eb00+LF, $fb00+LF

.bltcon1
	dc.w	(%000<<2)+%0000011	; #6
	dc.w	(%100<<2)+%0000011	; #7
	dc.w	(%010<<2)+%0000011	; #5
	dc.w	(%101<<2)+%0000011	; #4

	dc.w	(%000<<2)+%1000011	; #6
	dc.w	(%100<<2)+%1000011	; #7
	dc.w	(%010<<2)+%1000011	; #5
	dc.w	(%101<<2)+%1000011	; #4

	;---- blitter fill
	
fill	move.l	doublebuffer(pc),a0
	lea	(64*height)-2(a0),a0
	
.wblt1	btst.b	#6,2(a6)
	bne.b	.wblt1
	
	move.l	a0,$50(a6)
	move.l	a0,$54(a6)
	clr.l	$64(a6)	
	move.l	#(((%1001<<8)+%11110000)<<16)+%10010,$40(a6)
	move.w	#(height<<6)+32,$58(a6)	

.wblt2	btst.b	#6,2(a6)
	bne.b	.wblt2

	;---- screen swapping

	lea	doublebuffer(pc),a0
	movem.l	(a0),d0-d1
	exg	d0,d1
	movem.l	d0-d1,(a0)
	
	lea	copperlist(pc),a0
	addi.l	#((32-20)/2)*2,d1
	move.w	d1,bitplaneptr-copperlist+6(a0)
	swap	d1
	move.w	d1,bitplaneptr-copperlist+2(a0)

	;---- waitvbl

	clr.w	$180(a6)

waitvbl	move.l	$4(a6),d0
	andi.l	#$1ff00,d0
	cmpi.l	#$13800,d0
	bne.b	waitvbl
	
	;----
	
	addq.w	#4,scroll
	
	btst.b	#6,$bfe001
	bne.w	mainloop

	;----

	rts

	;----
		
scroll	dc.w	0
count	ds.w	1

text	dc.b	'                '
	dc.b	'                '
	dc.b	'                '
	dc.b	'                '
	dc.b	'                '
	dc.b	'                '
	dc.b	'AZATOTH         '
	dc.b	'THE             '
	dc.b	'MIGHTY          '
	dc.b	'GOD             '
	dc.b	'IS              '
	dc.b	'PROUD           '
	dc.b	'TO              '
	dc.b	'PRESENT         '
	dc.b	'                '
	dc.b	'                '
	dc.b	'                '
	dc.b	'THE             '
	dc.b	'STAR            '  
	dc.b	'WARS            '
	dc.b	'SCROLLER        '
	dc.b	'                '
	dc.b	'                '
	dc.b	'                '
	dc.b	'IN THEORY       '
	dc.b	'THIS            '
	dc.b	'IS              '
	dc.b	'NOT             '
	dc.b	'POSSIBLE        '
	dc.b	'TO DO           '
	dc.b	'                '
	dc.b	'                '
	dc.b	'                '
	dc.b	'BUT             '
	dc.b    'AS              ' 
	dc.b	'ALWAYS          '
	dc.b	'PHENOMENA       '
	dc.b	'BEATS           '
	dc.b	'ALL             '
	dc.b	'ODDS            ' 
	dc.b	'                '
	dc.b	'                '
	dc.b	'                '
	dc.b	'IF YOU          '
	dc.b	'WANNA           '
	dc.b	'CONTACT ME      '
	dc.b	'THEN WRITE      '
	dc.b	'TO              '	
	dc.b	'                '
	dc.b	'                '
	dc.b	'                '
	dc.b	'AZATOTH         '
	dc.b	'                '
	dc.b	'SANDVIKS        '
	dc.b	'VAGEN 99        '
	dc.b	'                '
	dc.b	'16240           '
	dc.b	'VALLINGBY       '
	dc.b	'                '
	dc.b	'SWEDEN          '
	dc.b	'                '
	dc.b	'                '
	dc.b	'                '
	dc.b	'IN CASE         '
	dc.b	'YOU HAVE        '
	dc.b	'SOME            '
	dc.b	'NICE            '
	dc.b	'                '
	dc.b	'PICS            '
	dc.b	'ANIMS           '
	dc.b	'LOGOS           '
	dc.b	'SAMPLES         '
	dc.b	'TUNES           '
	dc.b	'OR              '
	dc.b	'DEMO            '
	dc.b	'IDEAS           '
	dc.b	'                '
	dc.b	'THEN            '
	dc.b	'SEND            '
	dc.b	'THEM            '
	dc.b	'OVER            '
	dc.b	'AND             '
	dc.b	'I WILL          '
	dc.b	'USE THEM        '
	dc.b	'IN              '
	dc.b	'MY TWO          '
	dc.b	'COMING          '
	dc.b	'DEMOS           '
	dc.b	'                '
	dc.b	'                '
	dc.b	'                '
	dc.b	'ALSO            '
	dc.b	'LOOK OUT        '
	dc.b	'FOR MY          '
	dc.b	'PUBLIC          '
	dc.b	'DOMAIN          '
	dc.b	'RAY             '
	dc.b	'TRACER          '
	dc.b	'WICH            '
	dc.b	'WILL BE         '
	dc.b	'VERY            '
	dc.b	'FAST            '
	dc.b	'                '
	dc.b	'                '
	dc.b	'                '
	dc.b	'AND             '
	dc.b	'AFTER           '
	dc.b	'THE             '
	dc.b	'SUMMER          '
	dc.b	'MAYBE           '
	dc.b	'YOU             '
	dc.b	'WILL BE         '
	dc.b	'ABLE            '
	dc.b	'TO              '
	dc.b	'ENJOY MY        '
	dc.b	'                '
	dc.b	'VECTOR          '
	dc.b	'GAME            '
	dc.b	'                '
	dc.b	'                '
	dc.b	'                '
	dc.b	'BUT NOW         '
	dc.b	'LETS            '
	dc.b	'CONTINUE        '
	dc.b	'WITH            '
	dc.b	'THE             '
	dc.b	'DEMO            '
	dc.b	'                '
	dc.b	'                '
	dc.b	'                '
	dc.b	'                '
	dc.b	'                '
	dc.b	'                '

endtext	dc.b	0

	EVEN

vectors	ds.w	0
	ds.w	4*6*(13*6)
rr	dc.b	'sebo'

indent	ds.l	(endtext-text)/16

doublebuffer
	dc.l	bitplane1	; screen buffer
	dc.l	bitplane2	; draw buffer

copperlist
	dc.w	$8e,$2c81
	dc.w	$90,$2cc1
	dc.w	$92,$38
	dc.w	$94,$d0
	dc.w	$100,$0200
	dc.w	$102,0
	dc.w	$108,(32-20)*2
	dc.w	$10a,(32-20)*2
	
wait	SET	170

	dc.w	(wait<<8)+1,$fffe	

bitplaneptr
	dc.w	$e0,0
	dc.w	$e2,0
	dc.w	$100,$1200

wait	SET	wait+3	
shade	SET	0
	
	REPT	15
wait	SET	wait+3
	dc.w	(wait<<8)+1,$fffe	
	dc.w	$182,shade
shade	SET	shade+1
	ENDR
	
	dc.l	-2	; copper end

	;----

	SECTION	DATA_C

	include	charset.s

	SECTION	DATA_C
	
bitplane1
	ds.w	32*256		; 16KB
	
bitplane2
	ds.w	32*256		; 16KB

	SECTION	DATA_C

sincos	incbin	sincos16

	SECTION	DATA_C
	
projection
	ds.w	256*256		; 128KB projection table
	dc.b	'sebo'

	SECTION	DATA_C

rotate	ds.w	2*600
	dc.b	'sebo'

