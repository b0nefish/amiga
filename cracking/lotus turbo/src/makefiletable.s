
makeftable
	lea	table(pc),a0	;
	lea	end(pc),a1	;
	sub.l	a0,a1		;
	move.l	a1,d0		;
	lsr.w	#3,d0		;
	subq.w	#1,d0		; file count
	move.l	#$10525,d1	; disk base offset

.loop	tst.l	(a0)		;
	ble.b	.skip		;
	move.l	d1,4(a0)	;
	add.l	(a0),d1		;
.skip	lea	8(a0),a0	;
	dbf	d0,.loop	;

	rts			;

	;----

table	incbin	/bin/filetable	
end	dc.b	'sebo'
