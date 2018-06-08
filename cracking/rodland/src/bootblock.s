
check	lea 	boot(pc),a0
        move.l	a0,a1
        clr.l	4(a0)
        move.w	#(1024/4)-1,d7
        moveq	#0,d0
        moveq	#0,d1
.loop	add.l	(a0)+,d0
	addx.l	d1,d0
	dbf	d7,.loop
        not.l	d0
        move.l	d0,4(a1)
        rts
        
	;----

key	EQU	$ae3b9ce3
trainer	EQU	1

	;---- new bootblock for rodland v1.32

boot	dc.b	'DOS',0
	ds.l	1
	dc.l	880

	;----

	move.l	a1,-(sp)

	move.l	4.w,a6
	move.l	#204800,d0
	moveq	#3,d1
	jsr	-198(a6)
	
	move.l	(sp)+,a1
	
	tst.l	d0
.error	beq.b	.error
	
	lea	ptr(pc),a0
	move.l	d0,(a0)
	
	;----
	
	move.w	#2,$1c(a1)	
	move.l	#17*(11*512),$24(a1) 
	move.l	ptr(pc),$28(a1)	 
	move.l	#2*(11*512),$2c(a1) 			
	jsr	-456(a6)

	move.w	#9,$1c(a1)	;	 			
	clr.l	$24(a1)		;
	jsr	-456(a6)	; stop drive

	;----
	
	move.l	ptr(pc),a0	;	 
	jsr	propack(pc)	; decrunch
	
	;----
	
	jsr	-132(a6)	; forbid
	jsr	-120(a6)	; disable
	jsr	-150(a6)	; superstate

	lea	$7ff00.l,sp	;
	move.w	#$2700,sr	;

	move.w	#$7fff,$dff096	;
	move.w	#$7fff,$dff09a	;
	move.w	#$0200,$dff100	;
	move.w	#$008f,$dff180	;

	;----

	lea	reloc(pc),a0
	lea	$7ff00.l,a1
	move.w	#(propack-reloc)-1,d7
.loop	move.b	(a0)+,(a1)+
	dbf	d7,.loop
	
	move.l	ptr(pc),a0
	jmp	$7ff00.l

	;----
	
reloc	lea	$100.w,a1
	move.w	#(204800/4)-1,d7
.loop	move.l	(a0)+,(a1)+
	dbf	d7,.loop
	
	;---- disable checksums	
	
	move.l	#$70004e71,d0	;
	move.l	#$72004e71,d1	;
	
	move.l	d0,$4eee.w	;
	move.l	d0,$52fc.w	;
	move.l	d1,$f55c.l	;

	;---- patch copylock

	lea	$43aa.w,a0	; patch copylock
	move.w	#$203c,(a0)+	;
	move.l	#key,(a0)+	;
	move.w	#$21c0,(a0)+	;
	move.w	#$0060,(a0)+	;
	move.w	#$21c0,(a0)+	;
	move.w	#$3a6a,(a0)+	;
	move.w	#$4e71,(a0)+	;

	;---- trainer
	
	IFNE	trainer
	
	lea	$b360.l,a0
	
	REPT	5
	move.w	#$4e71,(a0)+	; disable live count
	ENDR
	
	ENDC

	;----
	
	jmp	$100.w

	;----

propack	incbin	propack

	;----
	
ptr	ds.l	1

padding	ds.b	1024-(padding-boot)

end
