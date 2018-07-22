	; Golden Axe file look up table

offset	SET	$eb7e		; <= disk base offset

	;----

	;dc.l	0,0		; $00

	dc.l	offset,$1272	; $01
offset	SET	offset+$1272	

	dc.l	offset,$2546	; $02
offset	SET	offset+$2546	

	dc.l	offset,$2d9c	; $03
offset	SET	offset+$2d9c	

	dc.l	offset,$17f8	; $04
offset	SET	offset+$17f8	

	dc.l	offset,$1830	; $05
offset	SET	offset+$1830	

	dc.l	offset,$16b2	; $06
offset	SET	offset+$16b2	

	dc.l	offset,$28d9	; $07
offset	SET	offset+$28d9	

	dc.l	offset,$5641	; $08
offset	SET	offset+$5641	

	dc.l	offset,$3f27	; $09
offset	SET	offset+$3f27	

	dc.l	offset,$591a	; $0a
offset	SET	offset+$591a	

	dc.l	offset,$da8	; $0b
offset	SET	offset+$da8	

	dc.l	offset,$da8	; $0c
offset	SET	offset+$da8	

	dc.l	offset,$da8	; $0d
offset	SET	offset+$da8	

	dc.l	offset,$da8	; $0e
offset	SET	offset+$da8	

	dc.l	offset,$da8	; $0f
offset	SET	offset+$da8	

	dc.l	offset,$da8	; $10	
offset	SET	offset+$da8	

	dc.l	offset,$63db	; $11 
offset	SET	offset+$63db	

	dc.l	offset,$5e73	; $12
offset	SET	offset+$5e73	

	dc.l	offset,$6b49	; $13
offset	SET	offset+$6b49	

	dc.l	offset,$46f7	; $14
offset	SET	offset+$46f7	

	dc.l	offset,$462c	; $15	
offset	SET	offset+$462c	

	dc.l	offset,$3edc	; $16
offset	SET	offset+$3edc	

	dc.l	offset,$46ca	; $17
offset	SET	offset+$46ca	

	dc.l	offset,$2a13	; $18
offset	SET	offset+$2a13	

	dc.l	offset,$6a40	; $19
offset	SET	offset+$6a40		

	dc.l	offset,$6e9a	; $1a	
offset	SET	offset+$6e9a	

	dc.l	offset,$6b5d	; $1b
offset	SET	offset+$6b5d	

	dc.l	offset,$6b13	; $1c
offset	SET	offset+$6b13	

	dc.l	offset,$550f	; $1d
offset	SET	offset+$550f	

	dc.l	offset,$6b2f	; $1e
offset	SET	offset+$6b2f	

	dc.l	offset,$6453	; $1f
offset	SET	offset+$6453

	;----	

	dc.l	offset,$48b2	; $20
offset	SET	offset+$48b2

	dc.l	offset,$38be	; $21
offset	SET	offset+$38be

	dc.l	offset,$400f	; $22	
offset	SET	offset+$400f

	dc.l	($400+$1800+$1610+$1070),$9340	; $23 (loader1 packed)

	dc.l	offset,$7541	; $24
offset	SET	offset+$7541


	dc.l	offset,$69e3	; $25
offset	SET	offset+$69e3

	dc.l	offset,$6ae7	; $26
offset	SET	offset+$6ae7

	dc.l	($400+$1800),$1610		; $27 (loader1 packed)

	dc.l	offset,$6949	; $28
offset	SET	offset+$6949

	dc.l	offset,$45f0	; $29
offset	SET	offset+$45f0

	dc.l	offset,$34e2	; $2a
offset	SET	offset+$34e2

	dc.l	offset,$5981	; $2b
offset	SET	offset+$5981

	dc.l	offset,$67fc	; $2c
offset	SET	offset+$67fc

	dc.l	offset,$5f27	; $2d
offset	SET	offset+$5f27

	dc.l	offset,$5d52	; $2e	
offset	SET	offset+$5d52

	dc.l	offset,$396a	; $2f
offset	SET	offset+$396a

	;----
	
	dc.l	offset,$b8e2	; $30
offset	SET	offset+$b8e2

	dc.l	($400+$1800+$1610),$1070	; $31 (loader1 packed)

	dc.l	offset,$20d4	; $32
offset	SET	offset+$20d4

