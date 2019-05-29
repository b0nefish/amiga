offset	SET	0

	dc.b	'SHO.boot'

	;---- SOH data files

	dc.b	'SLOG'
	dc.l	offset, $52*512

offset SET offset+($52*512)

	dc.b	'MUSC'
	dc.l	offset, $67*512	

offset SET offset+($67*512)

	dc.b	'LDSC'
	dc.l	offset, $40*512

offset SET offset+($40*512)

	dc.b	'GAME'
	dc.l	offset, $233*512
