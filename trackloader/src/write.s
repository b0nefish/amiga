
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
	
	bchg.b	#2,$100(a5)	; change head
	
	jsr	track0(pc)

	move.w	#8,d7
	jsr	move(pc)

	;jsr	write(pc)
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
	
	;----
	;---- write track

wordsync	EQU	$4859
gap		EQU	0
blocklen	EQU	5900	; block length

write	movem.l	d0-a6,-(sp)

	btst.b	#3,(a4)		; test disk write protection
	beq.w	.done		;

	;---- encode block

	lea	buffer(pc),a0	;
	lea	rawdata(pc),a1	;
	lea	6(a1),a1	;
	move.l	#$55555555,d6	;
	move.w	#(blocklen/4)-1,d7
.loop1	move.l	(a0)+,d0	; d0 = even bits
	move.l	d0,d1		; d1 = odd bits
	lsr.l	#1,d1		;
	and.l	d6,d0		;
	and.l	d6,d1		;
	movem.l	d0/d1,(a1)	;
	lea	8(a1),a1	;
	dbf	d7,.loop1	;

	;----

	lea	rawdata(pc),a0	;
	move.w	#wordsync,(a0)+	; sync
	move.w	#$aaaa,d0	;
	move.w	d0,(a0)+	; 0 fill
	move.w	d0,(a0)+	; 0 fill
	andi.w	#1,d0		; carry bit
	swap	d0		;
	move.w	#blocklen-1,d7	;
.loop2	move.w	(a0),d0		;
	move.l	d0,d1		;
	move.l	d0,d2		;
	lsr.l	#2,d1		;
	or.w	d1,d2		; 
	eor.w	d6,d2		;  
	add.w	d2,d2		;
	or.w	d2,d0		;
	move.w	d0,(a0)+	;
	andi.w	#1,d0		; carry bit
	swap	d0		;
	dbf	d7,.loop2	;

	;---- write to disk

	lea	rawdata(pc),a0
	move.l	a0,$20(a6)
	move.w	#$4000,$24(a6)
	move.w	#%1000001000010000,$96(a6)
	move.w	#%0000000000000010,$9c(a6)
	move.w	#%0111111100000000,$9e(a6)
	move.w	#%1001000100000000,$9e(a6)
	move.w	#$c000!(blocklen+3),d0  
	move.w	d0,$24(a6)
	move.w	d0,$24(a6)

.wait	btst.b	#1,$1f(a6)
	beq.b	.wait

	move.w	#$4000,$24(a6)

.done	movem.l	(sp)+,d0-a6	
	rts

	;----
	;---- load track

load	movem.l	d0-a6,-(sp)

	lea	rawdata(pc),a0
	move.l	a0,$20(a6)
	move.w	#$4000,$24(a6)
	move.w	#wordsync,$7e(a6)
	move.w	#%1000001000010000,$96(a6)
	move.w 	#%0000000000000010,$9c(a6)
	move.w	#%0111111100000000,$9e(a6)
	move.w	#%1001010100000000,$9e(a6)
	move.w	#$8000!(blocklen+3),d0
	move.w	d0,$24(a6)	
	move.w	d0,$24(a6)	

.wait	btst.b	#1,$1f(a6)	; wait dma disk
	beq.b	.wait		;

	move.w	#$4000,$24(a6)
	
	;---- decode block

	move.l	#$aaaaaaaa,d6	;

	lea	rawdata(pc),a0	;
	cmp.l	(a0)+,d6	;
	bne.b	.done		;

	lea	buffer(pc),a1	;
	lsr.l	#1,d6		;
	move.w	#(blocklen/4)-1,d7
.loop	movem.l	(a0)+,d0/d1	; d0 = even bits
	and.l	d6,d0		; d1 = odd bits
	and.l	d6,d1		;
	add.l	d1,d1		;
	or.l	d1,d0		; combine even/odd bits
	move.l	d0,(a1)+	; write decoded data
	dbf	d7,.loop	;

.done	movem.l	(sp)+,d0-a6	;
	rts			;

	;----
	;---- buffers

rawdata	ds.w	blocklen+3
	dc.b	'sebo'

buffer	;dc.b	'test ecriture disk. les donnees sont ecrites au format non dos'
	ds.b	blocklen
ii	dc.b	'sebo'	
