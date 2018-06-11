
check	lea 	boot(pc),a0
        clr.l	4(a0)
        move.w	#(1024/4)-1,d7
        moveq	#0,d0
        moveq	#0,d1
.loop	add.l	(a0)+,d0
	addx.l	d1,d0
	dbf	d7,.loop
        not.l	d0
        rts
        
boot	incbin	'hd1:cracking/parasol stars/crack/boot'

