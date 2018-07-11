
	lea	data,a0
	lea	buffer,a1
	include	bytekiller.s

data	incbin	'hd0:cracking/golden axe/disk1/file$23.pack'
buffer	ds.b	$20000
