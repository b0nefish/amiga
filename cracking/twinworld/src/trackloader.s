
	SECTION	trackloader,CODE_C
	
	;OPT	P+

	include	startup.s

	lea	target,a0
	lea	filetable(pc),a1
	moveq	#0,d0		; file index
	mulu.w	#20,d0
	lea	(a1,d0.l),a1
	jsr	loadfile(pc)
	move.l	d0,length
	rts

	;----
	; Files ripper

ripper	lea	target(pc),a0	;
	lea	filetable(pc),a1;
	lea	$0*20(a1),a1	; start file pointer
	moveq	#0,d6		;
	move.w	#10-1,d7	; read 10 files	
.loop	jsr	loadfile(pc)	; load
	add.l	d0,d6		;
	lea	(a0,d0.l),a0	; update target pointer
	lea	20(a1),a1	; next file
	dbf	d7,.loop	;
	move.l	d6,length	; return length
	rts

	;---- 
	; Twinworld 
	;
	; Trackloader
	;
	; >a0 = target ptr
	; >a1 = file pointer
	; d0> = file length

loadfile
	movem.l	d1-a6,-(sp)

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

	movem.l	(a1),d0-d1	; d0 = track ; d1 = file length	 
	bclr.b	#2,$100(a5)	; fix head
	cmpi.w	#80,d0		; 
	blt.b	.read		;
	bchg.b	#2,$100(a5)	; change side
	subi.w	#80,d0		;
.read	move.w	d0,d7		;
	jsr	track0(pc)	;
	jsr	move(pc)	;
	jsr	load(pc)	;

.copy	lea	decode,a2	;
	move.w	#6032-1,d7	;
.loop	move.b	(a2)+,(a0)+	; copy byte
	subq.l	#1,d1		;
	dble	d7,.loop	;

	tst.l	d1		; enought data ?
	beq.b	.done		; yep => done
	
	jsr	next(pc)	; nop => go next track
	jsr	load(pc)	; load it
	bra.b	.copy		; goto to copy loop

	;----

.done	bset.b	#3,$100(a5)	; stop drive
	bset.b	#7,$100(a5)	;
	bclr.b	#3,$100(a5)	;
	bset.b	#3,$100(a5)	;

	;----

	move.l	4(a1),d0	; return file length
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
	move.l	#1508-1,d7	; 1 track = 6032 bytes
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

length
	ds.l	1

filetable
	;dc.l	1,$afc8,0,0,0	; bootstrap
	incbin	/bin/filetable

trackinfo
	ds.l	1

rawdata	ds.w	readtracklen
	dc.b	'sebo'

decode	ds.b	6032
	dc.b	'sebo'

target	ds.b	$afc8
kk	dc.b	'sebo'	
