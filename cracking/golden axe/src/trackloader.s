
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

	;---- custom read

	;jsr	track0(pc)
	;bset.b	#2,$100(a5)
	;moveq	#1,d7
	;jsr	move(pc)
	;jsr	load(pc)

	;---- load file table

	lea	filetable(pc),a0
	moveq	#0,d0
	jsr	loadfile(pc)

	;----
	
	lea	target(pc),a0
	move.w	#$31,d0
	jsr	loadfile(pc)
	move.l	d0,length

	;----

	bset.b	#3,$100(a5)	; stop drive
	bset.b	#7,$100(a5)	;
	bclr.b	#3,$100(a5)	;
	bset.b	#3,$100(a5)	;
	
	;----
	
	rts

	;---- golden axe file loader
	; a0 = target ptr
	; d0 = file index

loadfile
	lea	filetable(pc),a1
	lsl.w	#3,d0
	movem.l	(a1,d0.w),d0/d1	; d0 = disk offset ; d1 = file length	
	move.l	d1,d6		;
	ble.b	.done		;
	divu.w	#6*1024,d0	;
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

.copy	lea	buffer(pc),a1	;
	lea	(a1,d0.w),a1	;
	move.w	#6*1024,d7	;
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

.done	move.l	d6,d0		; return file length in d0
	rts

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
	
	;---- delay

delay	move.b	#%10000001,$d00(a4)
	move.b	#%00001000,$e00(a4)
	move.b	#$22,$400(a4)
	move.b	#$0c,$500(a4)	; start oneshoot timer
.wait	btst.b	#0,$d00(a4)
	beq.b	.wait
	rts

	;---- load track

wordsync	EQU	$4489
readtracklen	EQU	$2000
retry		EQU	4
index		EQU	0
decode		EQU	1

load	movem.l	d0-a3,-(sp)
	moveq	#retry,d7
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

	;---- Golden Axe track decoder

.decode	lea	buffer,a1	;
	moveq	#6-1,d6		; 6 blocks

.loop1	cmpi.w	#wordsync,(a0)+	; sync
	bne.b	.loop1		;
	cmpi.w	#wordsync,(a0)	;
	beq.b	.loop1		;

	;----
 
	movem.w	4(a0),d0-d2	; decode block informations
				;
	REPT	8		;
	lsl.w	#1,d0		;
	lsl.l	#1,d0		;
	lsl.w	#1,d1		;
	lsl.l	#1,d1		;
	lsl.w	#1,d2		;
	lsl.l	#1,d2		;
	ENDR			;
				;
	swap	d0		;
	swap	d1		;
	swap	d2		;
				;
	cmpi.b	#6,d0		;
	bhi.b	.error		;
	ext.w	d0		;
	subq.w	#1,d0		;
	mulu.w	#1024,d0	;

	;----

	lea	10(a0),a0	; skip block header
	lea	(a1,d0.l),a2	;
	move.w	#1024-1,d7	;
				;
.loop2	move.w	(a0)+,d0	;
	REPT	8		;
	lsl.w	#1,d0		;
	lsl.l	#1,d0		;
	ENDR 			;
	swap	d0		;
	move.b	d0,(a2)+	;
	dbf	d7,.loop2	;
	dbf	d6,.loop1	; next block

	;----

	movem.l	(sp)+,d0-a3
	rts

.error	subq.w	#1,d7		; retry dma transfert
	bpl.w	.retry		;
	move.w	#$7fff,$96(a6)	;
	move.w	#$7fff,$9a(a6)	;
.die	move.w	$6(a6),$180(a6)	;
	bra.b	.die		; load error => die.
	
	;----

length	ds.l	1

infos	ds.l	3

rawdata	ds.w	readtracklen
	dc.b	'sebo'

buffer	ds.b	1024*6
k	dc.b	'sebo'

filetable
	dc.l	$efc00,$198	; file table location
	ds.b	$198-8		;
	dc.b	'sebo'

target	ds.b	$15000
	dc.b	'sebo'	
