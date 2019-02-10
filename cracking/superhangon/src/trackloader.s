
	SECTION	code,CODE_C
	
	include	startup.s
	
trackloader
	lea	$dff000,a6	;
	lea	$bfd000,a5	; ciab
	lea	$bfe001,a4	; ciaa

	move.b	#%11111111,$100(a5)
	bclr.b	#7,$100(a5)	; motor on
	bclr.b	#3,$100(a5)	; df0
	
	btst.b	#2,(a4)		; check disk inserted
	beq.b	.quit		;
.wait	btst.b	#5,(a4)		; wait disk ready
	bne.b	.wait		;

	;----

	jsr	track0(pc)	; go track 0

	moveq	#2-1,d7		; start track
	jsr	track(pc)	;
	
	;----
	
.next	jsr	load(pc)	; load both side
	bchg.b	#2,$100(a5)	;
	jsr	load(pc)	;
	bchg.b	#2,$100(a5)	;
	lea	count(pc),a0	;
	addq.w	#1,(a0)		; 
	cmpi.w	#20,(a0)	; number of track to be read
	beq.b	.stop		;
	jsr	step(pc)	; next track 
	bra.b	.next		;
	
	;----
	
.stop	bset.b	#3,$100(a5)	; stop df0
	bset.b	#7,$100(a5)	;
	bclr.b	#3,$100(a5)	;
	bset.b	#3,$100(a5)	;

.quit	rts

	;---- seek track 0

track0	btst.b	#4,(a4)		; seek track 0
	beq.b	.done		;
	bset.b	#1,$100(a5)	; change direction
.loop	bclr.b	#0,$100(a5)	; step pulse
	nop			;
	nop			;
	nop			;
	nop			;
	bset.b	#0,$100(a5)	;
	bsr.b	delay		;
	btst.b	#4,(a4)		;
	bne.b	.loop		;
.done	bclr.b	#1,$100(a5)	; change direction
	bsr.b	delay		;
	rts			;

	;---- set track

track	bclr.b	#0,$100(a5)	; step pulse
	nop			;
	nop			;
	nop			;
	nop			;
	bset.b	#0,$100(a5)	;
	bsr.b	delay		;
	dbf	d7,track	;
	rts

	;---- step

step	bclr.b	#0,$100(a5)	; step pulse
	nop			;
	nop			;
	nop			;
	nop			;
	bset.b	#0,$100(a5)	;
	bsr.b	delay		;
	rts
	
	;---- delay with ciaa timer a

delay	move.b	#%10000001,$d00(a4)
	move.b	#%00001000,$e00(a4)
	move.b	#$cc,$400(a4)
	move.b	#$02,$500(a4)	; start timer (oneshoot)
.wait	btst.b	#0,$d00(a4)
	beq.b	.wait
	rts

	;---- load track

wordsync	EQU	$4489
dmalen		EQU	5656
decode		EQU	1
decrypt		EQU	1
checksum	EQU	1

load	move.w	#%1000001001010000,$96(a6)
	move.w 	#%0000000000000010,$9c(a6)
	move.w	#$4000,$24(a6)	
	lea	diskdata(pc),a0
	move.l	a0,$20(a6)
	move.w	#wordsync,$7e(a6)
	move.w	#%0111111100000000,$9e(a6)
	move.w	#%1001010100000000,$9e(a6)

	move.w	#$8000!dmalen,d0
	move.w	d0,$24(a6)
	move.w	d0,$24(a6)

.wait	btst.b	#1,$1f(a6)
	beq.b	.wait

	move.w	#$4000,$24(a6)

	IFEQ	decode
	
	rts
	
	ENDC

	;---- decode track
	
mask	EQU	$5555

	lea	20(a0),a0	; skip tiny sector

.sync	cmpi.w	#wordsync,(a0)+	; sync
	bne.b	load		;
	cmpi.w	#$2aaa,(a0)+	;
	bne.b	load		;

	lea	5640+2(a0),a1
	lea	buffer(pc),a2
	moveq	#0,d0
	moveq	#-1,d1

.wblt1	btst.b	#6,2(a6)
	bne.b	.wblt1
	
	move.l	#$0de4f000,$40(a6)	; D = (AC + BC\)
	move.l	d1,$44(a6)
	move.l	a1,$4c(a6)
	move.l	a0,$50(a6)
	move.l	a2,$54(a6)
	move.l	d0,$60(a6)
	move.l	d0,$64(a6)
	move.w	#mask,$70(a6)
	move.w	#(705<<6)+4,$58(a6)	; 1 block has 5640 bytes	

.wblt2	btst.b	#6,2(a6)
	bne.b	.wblt2

	IFEQ	decrypt

	rts

	ENDC
	
	;---- decrypt
	
	lea	buffer(pc),a0	;
	tst.w	(a0)		;
	bne.w	load		;
	
	btst.b	#2,$100(a5)	; 
	beq.b	.chksum		; decrypt only side 0

	lea	4(a0),a0
	move.l	#$12345678,d0
	move.w	#(5640/4)-1-1,d7
.loop1	eor.l	d0,(a0)
	move.l	(a0)+,d0
	dbf	d7,.loop1

	;---- checksum
	
.chksum	
	IFEQ	checksum

	rts

	ENDC

	lea	buffer+2(pc),a0	;
	moveq	#0,d0		;
	move.w	(a0)+,d0	; get track number 
	move.w	#(5640/4)-2-1,d7
.loop2	add.l	(a0)+,d0	; sum
	dbf	d7,.loop2	;

	cmp.l	(a0),d0		; compare checksum
	bne.w	load		; retry if different

	;---- copy
	
	lea	buffer+4(pc),a0	;
	move.l	ptr(pc),a1	;
	move.l	(a1),a2		;
	move.w	#((512*11)/4)-1,d7
.copy	move.l	(a0)+,(a2)+	;
	dbf	d7,.copy	;
	move.l	a2,(a1)		;
		
	;----

	rts			; done
	
	;----

count	ds.w	1
ptr	dc.l	target
	
diskdata
	ds.w	dmalen	
	dc.b	'tail'

buffer	ds.w	705*4
	dc.b	'tail'

target	ds.b	512*11*2*20
end	dc.b	'tail'	
