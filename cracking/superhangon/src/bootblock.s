
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

boot	dc.b	'DOS',0
	ds.l	1
	dc.l	880
	
	;----
		
	move.w	#2,$1c(a1)
	move.l	#(512*11),$24(a1)
	move.l	#$72000,$28(a1)
	move.l	#(512*11*2),$2c(a1)
	
	move.l	4.w,a6
	jsr	-456(a6)	; doio
	
	;---- take system
	
	jsr	-132(a6)	; forbid
	jsr	-120(a6)	; disable
	jsr	-150(a6)	; superstate

	;----

	move.w	#$7fff,$dff096	;
	move.w	#$7fff,$dff09a	;
	move.w	#$0200,$dff100	;
	clr.w	$dff180		;

	;---- detect ram expansions

	moveq	#0,d0		;
		
.chip	cmpi.l	#$80000,62(a6)	; chipmem boundary
	ble.b	.fast		;
	move.l	#$80000,d0	;
	bra.b	.stack		;
	
.fast	tst.l	78(a6)		; fastmem boundary
	beq.b	.stack		;
	move.l	#$c00000,d0	;

	;----
	 
.stack	move.w	#$6800,d1	;
	lea	$300,a0		;
	lea	$180,sp		;
	move.l	d0,(sp)		; push ram address
	move.w	d1,4(sp)	;
	move.l	a0,usp		;
	
	;----
	
	jmp	$72000		; run program
	
	;----

padding	ds.b	(512*2)-(padding-boot)
end
