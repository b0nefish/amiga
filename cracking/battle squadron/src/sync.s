
track	EQU	79
	
	move.w	#track*2,d0	;
	move.w	#$4854,d1	;
	andi.w	#%111,d0	;
	ror.w	d0,d1		; d1 = sync
	rts			;	
