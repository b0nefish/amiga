
	SECTION	trackloader,CODE_C
	
	;OPT	P+

	include	startup.s

length	EQU	6144		; battle squadron track length

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
			
	jsr	track0(pc)	; go track 0

	;----

	lea	target,a0	;
	move.l	#'DMUS',d6	;
	move.w	#22-1,d7	;
	
	lea	files(pc),a1	;
.seek	cmp.l	2(a1),d6	;
	beq.b	.found
	lea	16(a1),a1	;
	dbf	d7,.seek	;
	bra.b	.done
	
.found	movem.l	8(a1),d0/d7	;
	tst.w	d0		;
	beq.b	.done		;

	divu.w	#24,d7		; 
	move.l	d7,d6		;
	swap	d6		;
	cmpi.w	#12,d6		;
	blt.b	.side0		;
	bchg.b	#2,$100(a5)	;
	subi.w	#12,d6		;
.side0	jsr	move(pc)	;
	jsr	load(pc)	;

	lea	buffer(pc),a1	;
	moveq	#12,d5		;
	sub.w	d6,d5		;
	lsl.w	#8,d5		;
	subq.w	#1,d5		;
	add.w	d6,d6		;
	lsl.w	#8,d6		;
	lea	12(a1,d6.w),a1	;
.loop1	move.w	(a1)+,(a0)+	;
	subq.w	#2,d0		;
	dble	d5,.loop1	;
	
.loop2	tst.w	d0		;
	ble.b	.done		;
	
	jsr	next(pc)	;
	jsr	load(pc)	;

	lea	buffer(pc),a1	;
	lea	12(a1),a1	;
	move.w	#(length/2)-1,d5
.loop3	move.w	(a1)+,(a0)+	;
	subq.w	#2,d0		;
	dble	d5,.loop3	;
	
	bra.b	.loop2		;

	;----

.done	bset.b	#3,$100(a5)	; stop drive
	bset.b	#7,$100(a5)	;
	bclr.b	#3,$100(a5)	;
	bset.b	#3,$100(a5)	;
	
	;----
	
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

next	bchg.b	#2,$100(a5)	;
	btst.b	#2,$100(a5)	;
	bne.b	.done		;
	jsr	step(pc)	;
	addq.w	#1,d7		;
.done	rts			;

	;---- step head

step	bsr.b	delay		;
	bclr.b	#0,$100(a5)	; step pulse
	nop			;
	nop			;
	nop			;
	nop			;
	bset.b	#0,$100(a5)	;
	bsr.b	delay		;
	rts			;
	
	;---- delay

delay	move.b	#%10000001,$d00(a4)
	move.b	#%00001000,$e00(a4)
	move.b	#$00,$400(a4)
	move.b	#$0c,$500(a4)	; start oneshoot timer
.wait	btst.b	#0,$d00(a4)
	beq.b	.wait
	rts

	;---- load track

readtracklen	EQU	6270
index		EQU	0
decode		EQU	1
copy		EQU	0

load	movem.l	d0-a3,-(sp)	;
	lea	rawdata(pc),a0	;
	
	add.w	d7,d7		;
	move.b	$100(a5),d1	; get side
	not.b	d1		;
	lsr.b	#2,d1		;
	andi.w	#1,d1		;
	add.w	d7,d1		;
	andi.w	#7,d1		;
	move.w	#$4854,d0	;
	ror.w	d1,d0		; d0 = track sync

	move.l	a0,$20(a6)
	move.w	#$4000,$24(a6)
	move.w	d0,$7e(a6)
	move.w	#%1000001001010000,$96(a6)
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
	
	movem.l	(sp)+,d0-a3
	rts
	
	ENDC

	;----
	
mask	EQU	$5555

	lea	rawdata(pc),a0
	moveq	#65-1,d7
.loop	cmpi.w	#$a44a,(a0)+
	dbeq	d7,.loop
	
	tst.w	d7
	bmi.b	.error

	lea	6150(a0),a1
	lea	buffer(pc),a2
	moveq	#0,d0
	moveq	#-1,d1
	
.wblt1	btst.b	#6,2(a6)
	bne.b	.wblt1
	
	move.l	#$0de4f000,$40(a6)
	move.l	d1,$44(a6)
	movem.l	a0-a2,$4c(a6)
	move.l	d0,$60(a6)
	move.l	d0,$64(a6)
	move.w	#mask,$70(a6)
	move.w	#(((6152/8)+1)<<6)+4,$58(a6)	

.wblt2	btst.b	#6,2(a6)
	bne.b	.wblt2

	;---- checksum
	
	lea	2(a2),a2	;
	move.l	4(a2),d0	; get track checksum
	clr.l	4(a2)		;
				
	moveq	#0,d1		;
	move.w	#(6152/4)-1,d7	;
.loop2	move.l	(a2)+,d2	;
	eor.l	d2,d1		;
	dbf	d7,.loop2	;
	
	;move.l	d0,sum
	;move.l	d1,sum+4
	
	cmp.l	d0,d1		; compare checksum
	bne.b	.error		;

	;---- copy

	IFNE	copy
	
	lea	buffer+10(pc),a0		
	move.w	#(length/4)-1,d7
.copy	move.l	(a0)+,(a3)+	
	dbf	d7,.copy	

	ENDC

	;----

	movem.l	(sp)+,d0-a3
	rts
	
	;----	

.error	move.w	6(a6),$180(a6)
	bra.b	.error
		
	;----

oo	ds.w	1
sum	ds.l	2

files	incbin	files

	;----

rawdata	ds.w	readtracklen
	dc.b	'sebo'

buffer	ds.b	6152+8
	dc.b	'sebo'

	;----

	SECTION	DATA_F

	dc.b	'sebo'
target	ds.b	length*2*10
end	dc.b	'sebo'
	
