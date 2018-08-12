
	SECTION	trackloader,CODE_C
	
	;OPT	P+

	include	startup.s

	lea	target,a0
	move.l	#257,d0
	move.l	a0,d1
	jsr	loader(pc)	
	rts

	;----
	; Files ripper

ripper	lea	target(pc),a0	;
	move.w	#$f8,d5		; first file
	moveq	#0,d6		;
	move.w	#8-1,d7	; 	

.loop	move.w	d5,d0		;	
	move.l	a0,d1		;
	jsr	loader(pc)	; load
	add.l	d0,d6		; sum file length	
	lea	(a0,d0.l),a0	; update target pointer
	addq.w	#1,d5		; next file
	dbf	d7,.loop	;

	move.l	d6,length	; push rip length
	rts			;

	;---- 
	;
	; Lotus Turbo Challenge
	;      Fileloader
	;
	; >d0 = file index
	; >d1 = target address
	; d0> = file length

loader	movem.l	d1-a6,-(sp)

	move.l	d1,a0		; a0 = target
	lea	filetable(pc),a1;
	lsl.w	#3,d0		;
	move.l	0(a1,d0.w),d1	; d1 = file length
	move.l	d1,d6		;
	ble.w	.quit 		;
	move.l	4(a1,d0.w),d0	; d0 = disk offset
	ble.w	.quit		;		

	;----
	
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
			
	divu.w	#6144,d0	; sector length 6144 bytes
	move.w	d0,d7		;
	lsr.w	#1,d7		;
	bclr.b	#2,$100(a5)	; fix head
	andi.w	#1,d0		; side ?
	beq.b	.read		;
	bchg.b	#2,$100(a5)	;
.read	swap	d0		;
	jsr	track0(pc)	;
	jsr	move(pc)	;
	jsr	load(pc)	;

.copy	lea	buffer(pc),a1	;
	lea	(a1,d0.w),a1	;
	move.w	#6144,d7	;
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

.quit	move.l	d6,d0		; return file length
	movem.l	(sp)+,d1-a6	;
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

	;---- move head

move	subq.w	#1,d7		;
	bmi.b	.done		;
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
	rts			;
	
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
readtracklen	EQU	6156
retry		EQU	4

load	movem.l	d0-a3,-(sp)
	move.w	#%1000001000010000,$96(a6)

.retry	lea	rawdata(pc),a0
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
	move.w 	#%0000000000000010,$9c(a6)

	;---- decoder

mask	EQU	$5555

.decode	lea	buffer,a1	;
	moveq	#0,d5		;
	move.w	#mask,d6	;
.sync	cmp.w	(a0)+,d6	;
	bne.b	.sync		;
	move.w	#(6144/2)-1,d7	; 
.loop	movem.w	(a0)+,d0/d1	;
	and.w	d6,d0		;
	and.w	d6,d1		;	
	add.w	d1,d1		;
	or.w	d1,d0		;
	move.w	d0,(a1)+	;
	add.w	d0,d5		; add checksum
	dbf	d7,.loop	;

	;---- checksum

	movem.w	(a0)+,d0/d1	;
	and.w	d6,d0		;
	and.w	d6,d1		;	
	add.w	d1,d1		;
	or.w	d1,d0		;

	cmp.w	d0,d5		; compare checksum
	bne.b	.retry		;

	;----

	movem.l	(sp)+,d0-a3	;
	rts			;
	
	;----

length	ds.l	1

filetable
	incbin	/bin/filetable	; files 0 to 255
	dc.l	$800,$3000	; file 256 (filetable)
	dc.l	$df48,$3800	; file 257 (bootstrap)

rawdata	ds.w	readtracklen
	dc.b	'sebo'

buffer	ds.b	6144
	dc.b	'sebo'

target	ds.b	$df48
end	dc.b	'sebo'
	
