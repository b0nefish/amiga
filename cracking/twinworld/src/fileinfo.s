
info	lea	table(pc),a0
	lea	end(pc),a1
	sub.l	a0,a1
	move.l	a1,d0
	divu.w	#20,d0
	move.w	d0,count
	
	subq.w	#1,d0
	moveq	#0,d1

.loop	add.l	4(a0),d1
	lea	20(a0),a0
	dbf	d0,.loop

	move.l	d1,size

	move.l	#(512*11*2*80)-1024-45000,d0
	sub.l	d0,d1
	move.l	d1,over
	rts

	;----

count	ds.w	1
size	ds.l	1
over	ds.l	1

	;----

table	incbin	/bin/filetable	
end
