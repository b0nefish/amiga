
wide	EQU	4

	lea	data(pc),a0
	move.w	#(end-data)/wide,d7
	jsr	decode(pc)	
	rts

	;----
	
encode	move.b	#$42,d0
	move.b	#$12,d1
	subq.w	#1,d7
.loop	eor.b	d0,(a0)
	add.b	d1,(a0)+
	dbf	d7,.loop
	rts
	
	;----

decode	move.b	#$42,d0
	move.b	#$12,d1
	subq.w	#1,d7
.loop	REPT	wide
	sub.b	d1,(a0)
	eor.b	d0,(a0)+
	ENDR
	dbf	d7,.loop
	rts
	
	;----
	
data	incbin	'hd1:cracking/dragon ninja/bin/main'
end
