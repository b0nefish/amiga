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

chrcnt	ds.w	1
scrlcnt	ds.b	1
text	dc.b	'THIS IS IMPOSSIBLE ! ROMANTIC OF EXALTY BACK TO THE VILLAGE AFTER 25 YEARS OF ABSENCE. -- ',0
        even