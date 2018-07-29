
	SECTION	trackloader,CODE_C
	
	OPT	P+

	;include	startup.s

	;----
	
	;lea	target,a0
	lea	table(pc),a1
	moveq	#1,d0
	mulu.w	#20,d0
	movem.l	(a1,d0.l),d0/d1	
	jsr	loadf(pc)
	rts

	;----

table	include	filetable.s	; file look up table
	ds.l	8		; gap

	;---- 
	; Twinworld 
	;
	; AmigaDOS File Loader
	;
	; >a0 = target ptr
	; >d0 = disk offset
	; >d1 = length
	; >d2 = 0
	; d0> = return code (0 = success, 1 = error)

loadf	bra.w	.load		;
	bra.w	.rts		;
	bra.w	.rts		;
	bra.w	.rts		;
	bra.w	.rts		;
	bra.w	.rts		;

	;----

.load	movem.l	d1-a6,-(sp)	;

	;----

	lea	$dff000,a6	;
	lea	$bfd000,a5	; ciab
	lea	$bfe001,a4	; ciaa

	;----

	cmpi.l	#(512*11*2*80)-1,d0
	bgt.w	.quit		;
	tst.l	d1		;
	ble.w	.quit		;

	;----

	move.b	#%11111111,$100(a5)
	bclr.b	#7,$100(a5)	; motor on
	bclr.b	#3,$100(a5)	; select df0

.ready	btst.b	#5,(a4)		; wait disk ready
	bne.b	.ready		;

	;----

	divu.w	#512*11,d0	;
	move.w	d0,d7		;
	lsr.w	#1,d7		; 
	bset.b	#2,$100(a5)	; fix head
	andi.w	#1,d0		; side ?
	beq.b	.read		;
	bchg.b	#2,$100(a5)	;
.read	swap	d0		;
	jsr	track0(pc)	;
	jsr	move(pc)	;
	jsr	load(pc)	;

.copy	;lea	decode,a1	;
	lea	$4500,a1	;
	lea	(a1,d0.w),a1	;
	move.w	#512*11,d7	;
	sub.w	d0,d7		;
	subq.w	#1,d7		;
.loop	move.b	(a1)+,(a0)+	; copy byte
	subq.l	#1,d1		; decrease length
	dble	d7,.loop	;

	tst.l	d1		; enought data ?
	beq.b	.done		; yep => done
	
	jsr	next(pc)	; nop => go next track
	jsr	load(pc)	; load it
	moveq	#0,d0		; zero copy offset
	bra.b	.copy		; goto to copy loop

	;----

.done	bset.b	#3,$100(a5)	; stop drive
	bset.b	#7,$100(a5)	;
	bclr.b	#3,$100(a5)	;
	bset.b	#3,$100(a5)	;

	;----

.quit	movem.l	(sp)+,d1-a6	; quit loader
	moveq	#0,d0		;
.rts	rts			;

	;---- go track 0

track0	btst.b	#4,(a4)		; track 0 ?
	beq.b	.done		;
	bset.b	#1,$100(a5)	; change direction
.loop	bclr.b	#0,$100(a5)	; step pulse
	nop			;
	nop			;
	nop			;
	nop			;
	bset.b	#0,$100(a5)	;
	bsr.b	delay		; delay
	btst.b	#4,(a4)		;
	bne.b	.loop		;
.done	bclr.b	#1,$100(a5)	; change direction
	bsr.b	delay		;
	rts			;

	;---- move head

move	subq.w	#1,d7
	bmi.b	.done
.loop	bclr.b	#0,$100(a5)	; step pulse
	nop			;
	nop			;
	nop			;
	nop			;
	bset.b	#0,$100(a5)	;
	bsr.b	delay		; delay
	dbf	d7,.loop	;
.done	rts			;

	;---- next track

next	btst.b	#2,$100(a5)	;
	bne.b	.done		;
.step	bclr.b	#0,$100(a5)	; step pulse
	nop			;
	nop			;
	nop			;
	nop			;
	bset.b	#0,$100(a5)	;
.done	bchg.b	#2,$100(a5)	;
	bsr.b	delay		; delay
	rts
	
	;---- cpu delay

delay	move.l	d7,-(sp)	;
	move.w	#2561-1,d7	;
.loop	nop			;
	dbf	d7,.loop	;
	move.l	(sp)+,d7	;
	rts			;

	;---- load track

wordsync	EQU	$4489
gap		EQU	350
readtracklen	EQU	((1088*11)/2)+gap

load	movem.l	d0-a3,-(sp)
	move.w	#%1000001000010000,$96(a6)

.retry	;lea	rawdata,a0
	lea	$400,a0
	move.l	a0,$20(a6)
	move.w	#$4000,$24(a6)
	move.w	#wordsync,$7e(a6)
	move.w 	#%0000000000000010,$9c(a6)
	move.w	#%0111111100000000,$9e(a6)
	move.w	#%1001010100000000,$9e(a6)
	move.w	#$8000!readtracklen,d0
	move.w	d0,$24(a6)
	move.w	d0,$24(a6)

.wait	btst.b	#1,$1f(a6)
	beq.b	.wait

	move.w	#$4000,$24(a6)

	;---- Amiga Track Decoder
	
mask	EQU	$55555555

.decode	;lea	decode,a1	;
	lea	$4500,a1	;
	moveq	#11-1,d6	;
	move.l	#mask,d0	;

.loop1	cmpi.w	#wordsync,(a0)+	; sync
	bne.b	.loop1		;
	cmpi.w	#wordsync,(a0)	;
	beq.b	.loop1		;

	move.l	a0,a2		;
	move.l	48(a0),d1	; d1 = header checksum 
	REPT	12		;
	move.l	(a2)+,d2	;
	eor.l	d2,d1		;
	ENDR			;
	and.l	d0,d1		;
	bne.w	.retry		; correct header checksum ?

	movem.l	(a0),d1/d2	; decode sector header
	and.l	d0,d1		; information
	and.l	d0,d2		;
	add.l	d1,d1		;
	or.l	d2,d1		;
	clr.b	d1		;
	add.w	d1,d1		; d1 = (sector number * 512)
	lea	(a1,d1.w),a2	; sector pointer

	lea	56(a0),a3	;
	lea	512(a3),a4	;
	move.l	52(a0),d2	; d2 = sector checksum
	moveq	#(512/4)-1,d5	; 

.loop2	move.l	(a3)+,d3	; odd bits
	move.l	(a4)+,d4	; even bits
	eor.l	d3,d2		;
	eor.l	d4,d2		;
	and.l	d0,d3		;
	and.l	d0,d4		;
	add.l	d3,d3		;
	or.l	d4,d3		;
	move.l	d3,(a2)+	; save decoded data
	dbf	d5,.loop2	;
	and.l	d0,d2		;
	bne.w	.retry		; correct sector checksum ?
	dbf	d6,.loop1	; next sector
	
	movem.l	(sp)+,d0-a3	;
	rts			;

end	;---- datas

rawdata	ds.w	readtracklen
	dc.b	'sebo'

decode	ds.b	512*11
	dc.b	'sebo'

target	ds.b	$20000
	dc.b	'sebo'	
