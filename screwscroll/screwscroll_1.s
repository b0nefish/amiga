	;---- precalc rotation
		
prerotate
	lea	sincos(pc),a0	
	lea	90*2(a0),a1
	lea	bitmap(pc),a2
	lea	(16+8)*42(a2),a2
	lea	rotate(pc),a3
	
	move.w	#0,d0		; angle
	add.w	d0,d0		;
	move.w	#0,d1		; y
	move.w	#16,d2		; z
	move.w	#180-1,d7	;
	
.loop	move.w	(a0,d0.w),d3	; d3 = sin(beta)
	move.w	(a1,d0.w),d4	; d4 = cos(beta)
	move.w	d3,d5		;
	move.w	d4,d6		;
	
	muls.w	d1,d4		; d4 = y * cos(beta) * k
	muls.w	d2,d3		; d3 = z * sin(beta) * k
	muls.w	d2,d6		; d6 = z * cos(beta) * k
	muls.w	d1,d5		; d5 = y * sin(beta) * k
	add.l	d3,d4		;
	sub.l	d5,d6		;
	add.l	d4,d4		;
	add.l	d6,d6		;
	swap	d4			; d4 = y'
	swap	d6			; d6 = z'
	muls.w	#42,d4		;
	lea		(a2,d4.l),a4
	move.l	a4,(a3)+	;
	move.w	d6,(a3)+	;
	addq.w	#2,d0		; next angle
	dbf	d7,.loop		;
	rts
	
	;----








scroll	lea		text(pc),a0
		lea		chrcnt(pc),a1
		lea		scrlcnt(pc),a2
		move.b  (a2),d0
		andi.b   #15,d0
		bne.b   .shift
		
		;---- copy new char

.char	move.w	(a1),d0
        addq.w	#1,(a1)
        move.b  (a0,d0.w),d0
        bne.b   .copy
        clr.w	(a1)
        bra.b   .char

.copy	subi.b	#32,d0
		ext.w	d0
		add.w	d0,d0

		lea     charset(pc),a0
		lea     (a0,d0.w),a0
        lea     bitmap(pc),a1
		lea		40(a1),a1
        move.l	#(%0000100100000000!$f0)<<16,d0
		moveq   #-1,d1
		move.l	#((60-2)<<16)!(42-2),d2

.wblt1	btst.b	#6,2(a6)
		bne.b	.wblt1

		movem.l	d0/d1,$40(a6)
        movem.l	a0/a1,$50(a6)   
        move.l	d2,$64(a6)
        move.w	#(16*64)+1,$58(a6)  

		;---- scroll bitmap

.shift	lea     bitmap(pc),a0
        lea     (42*16)-2(a0),a0
		move.l	a0,a1
		move.l  #((%0010100100000000!a)<<16)!%10,d0
        moveq   #-1,d1
		moveq	#0,d2

.wblt2	btst.b	#6,2(a6)
		bne.b	.wblt2

		movem.l	d0/d1,$40(a6) 
		movem.l	a0/a1,$50(a6)
		move.l	d2,$64(a6)
		move.w	#(16*64)+21,$58(a6)
		
		addq.b  #2,(a2)
        rts












		;----

screw	lea		bitmap(pc),a1
		lea		40*100(a1),a0
		move.l	a0,a2
		move.w	#(320/16)-1,d7
        move.l  #$00010001,d0
        move.w	#(16*64)+1,d1
		
		bsr.b	wblt

		move.l  #(%0000110100000000!($f0!b))<<16,$40(a6)
		move.w	#40-2,$62(a6)
        move.w	#42-2,$64(a6)
        move.w	#40-2,$66(a6)
          
.loop

        REPT    16
		bsr.b	wblt
        ror.l   #1,d0
        movem.l	a0-a2,$4c(a6)
        move.l	d0,$44(a6)
        move.w	d1,$58(a6)  
        ENDR
		
        lea		2(a0),a0
		lea		2(a1),a1
		lea		2(a2),a2
        dbf     d7,.loop
        rts
		
wblt	btst.b	#6,2(a6)
		bne.b	wblt
		rts











		;----

chrcnt	ds.w	1
scrlcnt	ds.b	1
text	dc.b	'THIS IS IMPOSSIBLE ! ROMANTIC OF EXALTY BACK TO THE VILLAGE AFTER 25 YEARS OF ABSENCE. -- ',0
        even
		
rotate
	ds.l	180
	ds.w	180		