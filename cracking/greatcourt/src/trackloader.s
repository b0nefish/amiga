
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

	move.w	#30-1,d7	; pause before loading
.wait1	bsr.w	delay		;
	dbf	d7,.wait1	;

	;----
	
	jsr	track0(pc)	;
				;
	moveq	#1,d7		;
	jsr	move(pc)	; go track 1

	;----
	
	lea	rawdata(pc),a0	;
	moveq	#10-1,d6	; load 10 tracks both sides
	
.loop	move.w	#wordsync,(a0)+

	bchg.b	#2,$100(a5)	; change head
.retry1	jsr	load(pc)	; load
	move.l	d1,-(sp)	;
	jsr	load(pc)	; reload
	cmp.l	(sp)+,d1	; compare checksum
	bne.b	.retry1		;
	
	lea	(readtracklen*2)(a0),a0
	move.w	#wordsync,(a0)+
	
	bchg.b	#2,$100(a5)	; change head
.retry2	jsr	load(pc)	; load
	move.l	d1,-(sp)	;
	jsr	load(pc)	; reload
	cmp.l	(sp)+,d1	; compare checksum
	bne.b	.retry2		;

	lea	(readtracklen*2)(a0),a0

	jsr	step(pc)
	dbf	d6,.loop

	;----

	move.w	#30-1,d7	; pause after loading
.wait2	bsr.w	delay		;
	dbf	d7,.wait2	;

	;----

	bset.b	#3,$100(a5)	; stop drive
	bset.b	#7,$100(a5)	;
	bclr.b	#3,$100(a5)	;
	bset.b	#3,$100(a5)	;
	
	;----
	
	rts

loadedtrack
	ds.l	1

checksum
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

	;---- step head

step	bclr.b	#0,$100(a5)	; step pulse
	nop			;
	nop			;
	nop			;
	nop			;
	bset.b	#0,$100(a5)	;
	bsr.b	delay		; delay
	rts			;
	
	;---- delay

delay	move.b	#%10000001,$d00(a4)
	move.b	#%00001000,$e00(a4)
	move.b	#$00,$400(a4)
	move.b	#$55,$500(a4)	; start oneshoot timer
.wait	btst.b	#0,$d00(a4)
	beq.b	.wait
	rts

	;---- load track

wordsync	EQU	$5542
readtracklen	EQU	(2+8+12064)/2
index		EQU	0
decode		EQU	1

load	move.l	a0,$20(a6)
	move.w	#$4000,$24(a6)
	move.w	#wordsync,$7e(a6)
	move.w	#%1000001000010000,$96(a6)
	move.w 	#%0000000000000010,$9c(a6)
	move.w	#%0111111100000000,$9e(a6)
	move.w	#%1001010100000000,$9e(a6)

	IFNE	index
	
	tst.b	$d00(a5)
.index	btst	#4,$d00(a5)
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
	
	;---- track decoder (no checksum)
	
mask	EQU	$55555555

.decode	move.l	a0,a1		;
	lea	2(a1),a1	;
	movem.l	(a1)+,d0/d1	;
	andi.l	#mask,d0	;
	andi.l	#mask,d1	;
	add.l	d0,d0		;
	or.l	d1,d0		;
	move.l	d0,d2		; get track information
	
	lea	buffer,a2	;
	moveq	#0,d3		;
	move.w	#1508-1,d7	;
.loop	movem.l	(a1)+,d0/d1	; get raw data
	andi.l	#mask,d0	;
	andi.l	#mask,d1	;
	add.l	d0,d0		;
	or.l	d1,d0		;
	eor.l	d0,d3		;
	move.l	d0,(a2)+	; save decoded data
	dbf	d7,.loop	;
	
	move.l	d2,d0		; d0 = track info
	move.l	d3,d1		; d1 = checksum
	rts
	
	;---- write track

writetracklen	EQU	1+readtracklen

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

rawdata	ds.w	(1+readtracklen)*2*10
end	dc.b	'stop'


	SECTION	DATA_F

buffer	ds.l	1508
	dc.b	'stop'

