	movea.l	4,a6
	jsr	_lvoforbid(a6)
	move.w	#$1af,$dff096
	move.w	#$2fb1,$dff09a
	move.w	#0,$dff180
	move.w	#2,$1c(a1)
	move.l	#$2800,$24(a1)
	move.l	#$50000,$28(a1)
	move.l	#$400,$2c(a1)
	jsr	-$1c8(a6)
	jmp	$50000