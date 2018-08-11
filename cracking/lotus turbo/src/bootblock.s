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

	; Lotus Turbo Challenge
	;	Bootblock

boot	dc.b	'DOS',0
	ds.l	1
	dc.l	880

	;----
	
	move.w	#%0000000110000000,$dff096	
	clr.w	$dff180

	;----

	move.w	#2,$1c(a1)
	move.l	#11*512*11,$24(a1)	; length
	move.l	#$50000,$28(a1)		; target
	move.l	#512*2,$2c(a1)		; offset
	
	move.l	4.w,a6
	jsr	-456(a6)	; doio (load filetable and bootstrap)	
	jsr	-132(a6)	; forbid
	jsr	-120(a6)	; disable
	jsr	-150(a6)	; superstate

	;----

	lea	$1000.w,sp
	move.w	#$7fff,$dff096
	move.w	#$7fff,$dff09a
	move.w	#$7fff,$dff09c

	;---- reloc this bootblock
	
	lea	.reloc(pc),a0
	lea	$40000.l,a1
	move.w	#(padding-.reloc)-1,d7
.loop	move.b	(a0)+,(a1)+
	dbf	d7,.loop

	jmp	$40000.l

	;----

.reloc	lea	$50000.l,a0	;
	lea	$400.w,a1	;
	move.w	#((256*8)/4)-1,d7
.loop1	move.l	(a0)+,(a1)+	; reloc filetable
	dbf	d7,.loop1	;

	lea	$72000.l,a1	;
	move.w	#(57160/4)-1,d7	;
.loop2	move.l	(a0)+,(a1)+	; reloc bootstrap
	dbf	d7,.loop2	;

	lea	$1000.w,a1	;
	move.w	#(1024/4)-1,d7	;
.loop3	move.l	(a0)+,(a1)+	; reloc trackloader
	dbf	d7,.loop3	;

	jmp	$72000.l	; bootstrap the game

	;----

padding	ds.b	(512*2)-(padding-boot)
end
