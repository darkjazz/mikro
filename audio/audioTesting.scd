(
~decoder = Decoder(
	isLocal: true, 
	isUHJ: true
);

~mikro = Mikro(
	liveInput: false,
	decoder: ~decoder,
	duration: 120,
	nCoef: 8
);

~rmap = #[
	bufplay,bufplay,tyhi,rwarp,
	bufplay,bufplay,rwarp,tyhi,
	swarp,swarp,bufmod,bufmod,
	swarp,swarp,bufmod,bufmod
];

~composer = MikroComposer(~mikro, ~rmap);

)