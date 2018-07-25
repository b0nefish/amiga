
	SECTION	trackloader,CODE_C
	
	;OPT	P+

	include	startup.s

	lea	target,a0
	moveq	#0,d0

	;---- 
	; Twinworld 
	;
	; AmigaDOS File Loader
	;
	; a0 = target ptr
	; d0 = file index

loadfile
	movem.l	d0-a6,-(sp)

	lea	$dff000,a6
	lea	$bfd000,a5	; ciab
	lea	$bfe001,a4	; ciaa

	;----

	move.b	#%11111111,$100(a5)
	bclr.b	#7,$100(a5)	; motor on
	bclr.b	#3,$100(a5)	; select df0

.ready	btst.b	#5,(a4)		; wait disk ready
	bne.b	.ready		;

	;----

	lea	filetable(pc),a1
	lsl.w	#3,d0		;
	movem.l	(a1,d0.w),d0/d1	; d0 = disk offset ; d1 = file length	

	divu.w	#6032,d0	;
	move.w	d0,d7		;
	lsr.w	#1,d7		; 
	bclr.b	#2,$100(a5)	; fix head
	;andi.w	#1,d0		; side ?
	;beq.b	.read		;
	;bchg.b	#2,$100(a5)	;
.read	swap	d0		;
	jsr	track0(pc)	;
	jsr	move(pc)	;
	jsr	load(pc)	;

.copy	lea	decode,a1	;
	lea	(a1,d0.w),a1	;
	move.w	#6032,d7	;
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

.quit	movem.l	(sp)+,d0-a6	;
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

wordsync	EQU	$5542
gap		EQU	0
readtracklen	EQU	$4004/2

load	movem.l	d0-a3,-(sp)
	move.w	#%1000001000010000,$96(a6)

.retry	lea	rawdata,a0	
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

	;---- Twinworld Track Decoder
	
mask	EQU	$55555555

.decode	move.l	#mask,d6	;
	movem.l	2(a0),d0/d1	;
	and.l	d6,d0		;
	and.l	d6,d1		;
	add.l	d0,d0		;
	or.l	d1,d0		; track info
	move.l	d0,trackinfo
	
	lea	10(a0),a0	;
	lea	decode(pc),a1	;
	move.l	#1508-1,d7	; 1 sector = 6032 bytes
lc4c52e	movem.l	(a0)+,d0/d1	;
	and.l	d6,d0		;
	and.l	d6,d1		;
	add.l	d0,d0		;
	or.l	d1,d0		;
	move.l	d0,(a1)+	;
	dbf	d7,lc4c52e	;

	movem.l	(sp)+,d0-a3	;
	rts			;

end	;---- datas

filetable
	dc.l	6032*2,45000

trackinfo
	ds.l	1

rawdata	ds.w	readtracklen
	dc.b	'sebo'

decode	ds.b	6032
	dc.b	'sebo'

target	ds.b	45000
	dc.b	'sebo'
kk	
