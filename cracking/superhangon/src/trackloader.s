****************************************
**             Super Hang On          ** 
**              Disk Loader           **
**        Compile with Devpac 2.15    **
****************************************

	SECTION	SHOLoader,CODE_C
	
	include	/src/startup.s

	;---- 

	lea	target(pc),a0	;
	lea	shogfx(pc),a1	;
	move.w	#0,d0		;
	jsr	loadfile(pc)	;
	move.l	d0,fname	;
	move.w	d1,fsize	;
	move.l	d2,loadlen	;

	rts

	;----
	; SuperHangOn
	;
	; Trackloader
	;
	; >a0 = target
	; >a1 = index
	; >d0 = file id
	; d0> = file name 
	; d1> = file size
	
loadfile
	movem.l	d2-a6,-(sp)
	
	lea	$dff000,a6	;
	lea	$bfd000,a5	; ciab
	lea	$bfe001,a4	; ciaa

	move.b	#%11111111,$100(a5)
	bclr.b	#7,$100(a5)	; motor on
	bclr.b	#3,$100(a5)	; df0

	btst.b	#2,(a4)		; check disk inserted
	beq.w	.done		;
.wait	btst.b	#5,(a4)		; wait disk ready
	bne.b	.wait		;

	;----

	move.w	(a1)+,d1	; get side
	beq.b	.a		;
	bchg.b	#2,$100(a5)	; change side

	;----

.a	lsl.w	#3,d0		;
	lea	8(a1,d0.w),a1	;
	
	moveq	#0,d0		;
	moveq	#0,d1		;
	moveq	#0,d2		;
	move.b	4(a1),d0	; start track
	move.b	5(a1),d1	; block
	move.w	6(a1),d2	; file size

	;----

	btst.b	#2,$100(a5)	; convert shoboot file
	beq.b	.b		; size in byte
	mulu.w	#512,d2		;

	;----

.b	jsr	track0(pc)	; go track 0

	move.w	d0,d7		;
	jsr	move(pc)	;

	;----

	lea	buffer(pc),a2	;
	mulu.w	#512,d1		;
	lea	4(a2),a3	;
	lea	4(a2,d1.l),a2	;

	move.w	#11*512,d7	;
	sub.w	d1,d7		;
	subq.w	#1,d7		;

	;----

.load	jsr	load(pc)	; load track

.loop	move.b	(a2)+,(a0)+	;
	subq.l	#1,d2		;
	dble	d7,.loop	;	
	
	tst.l	d2		; enought data ?
	beq.b	.done		; yes => leave
	jsr	next(pc)	; no  => next track

	lea	(a3),a2		;	
	move.w	#(11*512)-1,d7	;
	bra.b	.load		;

	;----
	
.done	bset.b	#3,$100(a5)	; stop df0
	bset.b	#7,$100(a5)	;
	bclr.b	#3,$100(a5)	;
	bset.b	#3,$100(a5)	;

	;----

.quit	move.l	(a1),d0		; return filename
	move.w	6(a1),d1	; return filesize
	movem.l	(sp)+,d2-a6	;
	rts

	;---- track 0

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

	;---- move head

move	subq.w	#1,d7		;
	bmi.b	.done		;
.loop	bclr.b	#0,$100(a5)	; step pulse
	nop			;
	nop			;
	nop			;
	nop			;
	bset.b	#0,$100(a5)	;
	bsr.b	delay		;
	dbf	d7,.loop	;
.done	rts			;

	;---- next track

next	bclr.b	#0,$100(a5)	; step pulse
	nop			;
	nop			;
	nop			;
	nop			;
	bset.b	#0,$100(a5)	;
	bsr.b	delay		; delay
	rts
	
	;---- delay with ciaa timer a

delay	move.b	#%10000001,$d00(a4)
	move.b	#%00001000,$e00(a4)
	move.b	#$cc,$400(a4)
	move.b	#$3a,$500(a4)	; start timer (oneshoot)
.wait	btst.b	#0,$d00(a4)
	beq.b	.wait
	rts

	;---- load track

wordsync	EQU	$4489
dmalen		EQU	5656
decode		EQU	1
checksum	EQU	1

load	movem.l	d0-a2,-(sp)

.retry	move.w	#%1000001001010000,$96(a6)
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

	;---- mfm decoder
	
mask	EQU	$5555

	lea	20(a0),a0	; skip tiny sector

.sync	cmpi.w	#wordsync,(a0)+	; sync
	bne.b	.retry		;
	cmpi.w	#$2aaa,(a0)+	;
	bne.b	.retry		;

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
	
	tst.w	(a2)		; when decoded first two bytes
	bne.w	.retry		; must be zero

	;---- decrypt

	btst.b	#2,$100(a5)	; decrypt shoboot data
	beq.b	.chksum		; only (side 0)		

	lea	buffer+4(pc),a0	;	
	move.w	#(5640/4)-2,d7	;
	move.l	#$12345678,d0	;
.loop2	eor.l	d0,(a0)		; runtime xor decryption
	move.l	(a0)+,d0	;
	dbf	d7,.loop2	;
	
	;---- checksum
	
.chksum	lea	buffer+2(pc),a0	;
	moveq	#0,d0		;
	move.w	(a0)+,d0	; get track number 
	move.w	#(5640/4)-3,d7	;
.loop3	add.l	(a0)+,d0	; sum
	dbf	d7,.loop3	;

	cmp.l	(a0),d0		; compare checksum
	bne.w	.retry		; retry if different

	;----

	movem.l	(sp)+,d0-a2
	rts
	
	;---- logs

fname	ds.l	1
fsize	ds.w	1
loadlen	ds.l	1

	;---- table

index0	dc.l	'IDX0'	; index for shoboot files
	dc.b	2,0
	dc.w	512

index1	dc.l	'IDX1'	; index for shografx files
	dc.b	1,0
	dc.w	512

shoboot	dc.w	0	; side 0
	; files length are in block (multiple of 512 bytes)
	; and are crypted on disk with xor runtime algorithm
	incbin	/bin/shoboot/table

shogfx	dc.w	1	; side 1
	; files length are in bytes
	; no encryption
	incbin	/bin/shografx/table

	;---- buffers
	
diskdata
	ds.w	dmalen	
	dc.b	'tail'

buffer	ds.w	705*4
	dc.b	'tail'

target	ds.b	$1cc8
	;ds.b	$233*512
	;ds.b	160398
	;ds.b	239616

end	dc.b	'tail'	
