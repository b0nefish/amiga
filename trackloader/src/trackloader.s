
	SECTION	trackloader,CODE_C
	
	;OPT	P+

	include	startup.s

trackloader
	lea	$dff000,a6
	lea	$bfd000,a5	; ciab
	lea	$bfe001,a4	; ciaa

	move.b	#%11111111,$100(a5)
	bclr.b	#7,$100(a5)	; motor on
	bclr.b	#3,$100(a5)	; select df0

.ready	btst.b	#5,(a4)		; wait disk ready
	bne.b	.ready		;

	;----
	
	;bchg.b	#2,$100(a5)	; change head
	
	jsr	track0(pc)
	jsr	load(pc)

	;----

	bset.b	#3,$100(a5)	; stop drive
	bset.b	#7,$100(a5)	;
	bclr.b	#3,$100(a5)	;
	bset.b	#3,$100(a5)	;
	
	;----
	
	rts

loadedtrack
	ds.l	1

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
	
	;---- delay

delay	move.b	#%10000001,$d00(a4)
	move.b	#%00001000,$e00(a4)
	move.b	#$00,$400(a4)
	move.b	#$0c,$500(a4)	; start oneshoot timer
.wait	btst.b	#0,$d00(a4)
	beq.b	.wait
	rts

	;---- load track

wordsync	EQU	$4489
gap		EQU	350
readtracklen	EQU	((1088*11)/2)+gap
retry		EQU	4
index		EQU	0
decode		EQU	0

load	moveq	#retry,d7
	move.w	#%1000001000010000,$96(a6)

.retry	lea	rawdata(pc),a0
	move.l	a0,$20(a6)
	move.w	#$4000,$24(a6)
	move.w	#wordsync,$7e(a6)
	move.w 	#%0000000000000010,$9c(a6)
	move.w	#%0111111100000000,$9e(a6)
	move.w	#%1001010100000000,$9e(a6)

	IFNE	index
	
	tst.b	$d00(a5)
.index	btst.b	#4,$d00(a5)
	beq.b	.index
	
	ENDC

	move.w	#$8000!readtracklen,d0
	move.w	d0,$24(a6)
	move.w	d0,$24(a6)

.wait	btst.b	#1,$1f(a6)
	beq.b	.wait

	move.w	#$4000,$24(a6)
	
	IFEQ	decode
	
	rts
	
	ENDC

	;---- Amiga Track Decoder
	
mask	EQU	$55555555

.decode	lea	buffer,a1
	moveq	#11-1,d6
	move.l	#mask,d0

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
	bne.b	.error		; correct header checksum ?

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
	bne.b	.error		; correct sector checksum ?
	dbf	d6,.loop1	; next sector
	
	moveq	#0,d0		;
	swap	d1		;
	lsr.b	#1,d1		; get loaded track 
	move.b	d1,d0		;
	rts

.error	subq.w	#1,d7		; retry dma transfert
	bpl.w	.retry		;
	move.w	#$7fff,$96(a6)	;
	move.w	#$7fff,$9a(a6)	;
.die	move.w	$6(a6),$180(a6)	;
	bra.b	.die		; load error => die.

	;---- write track

writetracklen	EQU	6317	; max 6317 dma words

write	btst.b	#3,(a4)		; test disk write protection
	beq.b	.done		;

	move.w	#%1000001000010000,$96(a6)
	lea	rawdata(pc),a0
	move.l	a0,$20(a6)
	move.w	#$4000,$24(a6)
	move.w	#%0000000000000010,$9c(a6)
	move.w	#%0111111100000000,$9e(a6)
	move.w	#%1001000100000000,$9e(a6)
	move.w	#$c000!writetracklen,d0  
	move.w	d0,$24(a6)
	move.w	d0,$24(a6)

.wait	btst.b	#1,$1f(a6)
	beq.b	.wait

	move.w	#$4000,$24(a6)
.done	rts
	
	;----

rawdata	;dcb.w	writetracklen,$4489
	ds.w	readtracklen
	dc.b	'sebo'

buffer	ds.b	512*11
	dc.b	'sebo'
	
