
	SECTION	trackloader,CODE_C
	
	;OPT	P+

	include	startup.s

	;----
	
	lea	buffer(pc),a0
	move.w	#0,d0
	jsr	loader(pc)
	rts

	;---- 
	;   DOS File Loader
	;
	; >d0 = file index
	; >a0 = target

ciatiming	EQU 1

loader	movem.l	d0-a6,-(sp)	;

	lea	table(pc),a1	;
	lsl.w	#3,d0		;
	move.l	0(a1,d0.w),d1	; d1 = file length
	ble.w	.quit 		;
	move.l	4(a1,d0.w),d0	; d0 = disk offset
	ble.w	.quit		;		

	;----

	lea	$dff000,a6	; custom chip
	lea	$bfd000,a5	; ciab
	lea	$bfe001,a4	; ciaa

	;----

	move.w	#wordsync,$7e(a6)
	move.w	#%1000001000010000,$96(a6)
	move.w	#%0111111100000000,$9e(a6)
	move.w	#%1001010100000000,$9e(a6)

	;----

	move.b	#%11111111,$100(a5)
	bclr.b	#7,$100(a5)	; motor on
	bclr.b	#3,$100(a5)	; select df0

.ready	btst.b	#5,(a4)		; wait disk ready
	bne.b	.ready		;

	;----
			
	move.l	d0,d6		; d6 = offset
	move.l	d1,d7		; d7 = length
	divu.w	#512*11,d6	;
	move.w	d6,d0		;
	lsr.w	#1,d0		;
	bset.b	#2,$100(a5)	; fix head
	andi.w	#1,d6		; side ?
	beq.b	.trk0		;
	bchg.b	#2,$100(a5)	; toggle head
.trk0	jsr	track0(pc)	;
	swap	d6		; get track offset

	;---- move head

	subq.w	#1,d0		;
	bmi.b	.load		;	
.loop0	bclr.b	#0,$100(a5)	; step pulse
	nop			;
	nop			;
	nop			;
	nop			;
	bset.b	#0,$100(a5)	;
	bsr.w	delay		; delay
	dbf	d0,.loop0	;

	;----

.load	movem.l	a4/a5,-(sp)	;

	lea	buffer(pc),a3	;
	lea	(a3,d6.w),a4	; upper target pointer	
	lea	(a4,d7.w),a5	; lower target pointer

	;---- load track

wordsync	EQU	$4489
gap		EQU	350
readtracklen	EQU	((1088*11)/2)+gap

.retry	lea	rawdata(pc),a2
	move.l	a2,$20(a6)
	move.w	#$4000,$24(a6)
	move.w 	#%0000000000000010,$9c(a6)
	move.w	#$8000!readtracklen,d0
	move.w	d0,$24(a6)
	move.w	d0,$24(a6)

.wait	btst.b	#1,$1f(a6)
	beq.b	.wait

	move.w	#$4000,$24(a6)
	move.w 	#%0000000000000010,$9c(a6)

	;---- AmigaDOS Track Decoder
	
mask	EQU	$55555555

.decode	moveq	#11-1,d5	;
	move.l	#mask,d0	;

.loop1	cmpi.w	#wordsync,(a2)+	; sync
	bne.b	.loop1		;
	cmpi.w	#wordsync,(a2)	;
	beq.b	.loop1		;

	move.l	a2,a3		;
	move.l	48(a2),d1	; d1 = header checksum 
	REPT	12		;
	move.l	(a3)+,d2	;
	eor.l	d2,d1		;
	ENDR			;
	and.l	d0,d1		;
	bne.w	.retry		; correct header checksum ?

	lea	buffer(pc),a3	;
	movem.l	(a2),d1/d2	; decode sector header
	and.l	d0,d1		; information
	and.l	d0,d2		;
	add.l	d1,d1		;
	or.l	d2,d1		;
	clr.b	d1		;
	add.w	d1,d1		; d1 = (sector number * 512)
	lea	(a3,d1.w),a1	; track pointer

	;---- checksum loop

	lea	56(a2),a3	;
	move.l	52(a2),d1	; d1 = block checksum
	move.w	#(512/4)-1,d4	; 
.loop2	move.l	(a3),d2		; odd bits
	move.l	512(a3),d3	; even bits
	eor.l	d2,d1		;
	eor.l	d3,d1		;
	lea	4(a3),a3	;
	dbf	d4,.loop2	;

	and.l	d0,d1		; 
	bne.w	.retry		; not zero ? load again

	;---- 1 byte precision decode loop

	lea	56(a2),a3	; mfm bitmap pointer
	move.w	#512-1,d4	; block size
.loop3	cmpa.l	a4,a1		; track pointer between
	blt.b	.out		; file boundary ?
	cmpa.l	a5,a1		; yes => copy
	bge.b	.out		; no  => next data
	move.b	(a3),d2		; odd bits
	move.b	512(a3),d3	; even bits
	and.b	d0,d2		;
	and.b	d0,d3		;
	add.b	d2,d2		;
	or.b	d3,d2		;
	move.b	d2,(a0)+	; save decoded byte
	subq.l	#1,d7		; decrease file length
.out	lea	1(a3),a3	; next byte in raw buffer
	lea	1(a1),a1	; move track pointer
	dbf	d4,.loop3	; next byte
	dbf	d5,.loop1	; next block

	movem.l	(sp)+,a4/a5	; restore cia base registers

	;----

	tst.l	d7		; more data ?
	ble.b	.done		; yes => load another track
	jsr	next(pc)	; no  => load done
	moveq	#0,d6		; zero track offset
	bra.w	.load		; load next track		
	
	;----

.done	bset.b	#3,$100(a5)	; stop drive
	bset.b	#7,$100(a5)	;
	bclr.b	#3,$100(a5)	;
	bset.b	#3,$100(a5)	;
	
	;----

.quit	movem.l	(sp)+,d0-a6	;
	rts			;

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
	
	;---- timing

delay
	IFNE	ciatiming
	move.b	#%10000001,$d00(a4)
	move.b	#%00001000,$e00(a4)
	move.b	#$00,$400(a4)
	move.b	#$0c,$500(a4)	; start oneshoot timer
.wait	btst.b	#0,$d00(a4)
	beq.b	.wait
	ENDC	

	IFEQ	ciatiming	;
	move.l	d7,-(sp)	;
	move.w	#2000,d7	; 
.loop	dbf	d7,.loop	;
	move.l	(sp)+,d7	;
	ENDC			;

	rts			;

	;---- data

rawdata	ds.w	readtracklen	; raw buffer

table	dc.l	2,$15ff
	incbin	'hd0:cracking/lotus turbo/bin/dosfiletable'

buffer	ds.b	2
	dc.b	'sebo'

