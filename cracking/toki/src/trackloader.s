
	SECTION	trackloader,CODE_C
	
	;OPT	P+

	include	startup.s

	lea	filetable(pc),a0
	lea	3*12(a0),a0

	;---- 
	; Toki 
	;
	; Trackloader
	;
	; >a0 = lookup file table 
	;

loadfile
	movem.l	d1-a6,-(sp)

	lea	$dff000,a6	; custom chip
	lea	$bfd000,a5	; ciab
	lea	$bfe001,a4	; ciaa

	;----

	move.b	#%11111111,$100(a5)
	bclr.b	#7,$100(a5)	; motor on
	bclr.b	#3,$100(a5)	; select df0

.ready	btst.b	#5,(a4)		; wait disk ready
	bne.b	.ready		;

	;----

	move.l	8(a0),d6	; d6 = file length
	move.l	4(a0),d7	; d7 = disk offset  

	lea	target(pc),a0	;

	divu.w	#6328,d7	;
	bset.b	#2,$100(a5)	; fix head
	cmpi.w	#80,d7		; 
	blt.b	.tk0		;
	bchg.b	#2,$100(a5)	; change side
	subi.w	#80,d7		;
.tk0	jsr	track0(pc)	;
	jsr	move(pc)	;
.load	jsr	load(pc)	;

	;----

	move.l	d7,d5		;
	swap	d5		;

.copy	lea	decode(pc),a1	;
	lea	(a1,d5.w),a1	;
	move.w	#6328,d4	;
	sub.w	d5,d4		;
	subq.w	#1,d4		;
.loop	move.b	(a1)+,(a0)+	; copy byte
	subq.l	#1,d6		; decrease length
	dble	d4,.loop	;

	tst.l	d6		; enought data ?
	ble.b	.done		; yes => done
	addq.w	#1,d7		; no  => next track
	jsr	next(pc)	;
	jsr	load(pc)	; load it

	moveq	#0,d5		;
	bra.b	.copy		; goto to copy loop

	;----

.done	bset.b	#3,$100(a5)	; stop drive
	bset.b	#7,$100(a5)	;
	bclr.b	#3,$100(a5)	;
	bset.b	#3,$100(a5)	;

	;----

	lea	target(pc),a0	;
	jsr	depack(pc)	;

	;----

.quit	movem.l	(sp)+,d1-a6	;
	rts			; quit loader

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

move	move.l	d7,-(sp)	;
	subq.w	#1,d7		;
	bmi.b	.done		;
.loop	bclr.b	#0,$100(a5)	; step pulse
	nop			;
	nop			;
	nop			;
	nop			;
	bset.b	#0,$100(a5)	;
	bsr.b	delay		; delay
	dbf	d7,.loop	;
.done	move.l	(sp)+,d7	;
	rts			;

	;---- next track

next	;btst.b	#2,$100(a5)	;
	;bne.b	.done		;
.step	bclr.b	#0,$100(a5)	; step pulse
	nop			;
	nop			;
	nop			;
	nop			;
	bset.b	#0,$100(a5)	;
.done	;bchg.b	#2,$100(a5)	;
	bsr.b	delay		; delay
	rts
	
	;---- delay (ciaa timer b)

delay	move.b	#%00001000,$f00(a4)
	move.b	#$c4,$600(a4)
	move.b	#$09,$700(a4)	; start oneshoot timer
.wait	btst.b	#0,$f00(a4)
	bne.b	.wait
	rts

	;---- load track
	
wordsync	EQU	$4488
readtracklen	EQU	6340

load	movem.l	d0-a3,-(sp)

	lea	rawdata,a0	
	move.l	a0,$20(a6)
	move.w	#$4000,$24(a6)

	move.l	#$41244488,d0
	btst.b	#2,$100(a5)
	bne.b	.sync
	cmpi.w	#55,d7	
	blt.b	.sync
	swap	d0	

.sync	move.w	d0,$7e(a6)
	move.w	#%1000001000010000,$96(a6)
	move.w 	#%0000000000000010,$9c(a6)
	move.w	#%0111111100000000,$9e(a6)
	move.w	#%1001010100000000,$9e(a6)
	move.w	#$8000!readtracklen,d0
	move.w	d0,$24(a6)
	move.w	d0,$24(a6)

.wait	btst.b	#1,$1f(a6)
	beq.b	.wait

	move.w	#$4000,$24(a6)

	;---- Toki Track Decoder
	
mask	EQU	$55555555

	move.l	#mask,d5	;

	;---- checksum		
	
	movem.l	(a0),d0/d1	;
	and.l	d5,d0		;
	and.l	d5,d1		;
	add.l	d1,d1		;
	or.l	d1,d0		;
	lsr.w	#8,d0		;
	cmp.w	d7,d0		; compare track index
	bne.b	.error		;
	swap	d0		;
	cmpi.w	#$5041,d0	;
	bne.b	.error		;

	;----

	moveq	#0,d2		; sum register
	move.w	#(6332/4)-1,d7	;

.sum	movem.l	(a0)+,d0/d1	;
	and.l	d5,d0		;
	and.l	d5,d1		;
	add.l	d0,d2		;
	add.l	d1,d2		;
	dbf	d7,.sum		;

	movem.l	(a0),d0/d1	;
	and.l	d5,d0		;
	and.l	d5,d1		;
	add.l	d1,d1		;
	or.l	d1,d0		; get checksum

	cmp.l	d0,d2		; compare checksum
	bne.b	.error		; leave if not equal		
	
	;---- decode

	lea	rawdata(pc),a0	;
	lea	8(a0),a0	;
	lea	decode(pc),a1	;
	move.w	#(6328/4)-1,d7	; 1 track has 6328 bytes
.loop	movem.l	(a0)+,d0/d1	;
	and.l	d5,d0		;
	and.l	d5,d1		;
	add.l	d1,d1		;
	or.l	d1,d0		;
	move.l	d0,(a1)+	;
	dbf	d7,.loop	;

.done	movem.l	(sp)+,d0-a3	;
	rts

	;---

.error	move.w	$6(a6),$180(a6)	;
	bra.b	.error		;

	;---- Ice Decrunch Routine

depack	incbin	/bin/icepacker

	;---- datas

tracknum
	ds.l	1

filetable
	dc.l	$23800,$d0908,$1ee60
	dc.l	$50858,$18b8,$16ef8
	dc.l	$d300,$8798c,$93d8
	dc.l	$60000,$94824,$db8c

rawdata	ds.w	readtracklen
	dc.b	'sebo'

decode	ds.b	6328
	dc.b	'sebo'
	
target	ds.b	$db8c
blank	ds.b	$1fd54-(blank-target)
end	dc.b	'sebo'
