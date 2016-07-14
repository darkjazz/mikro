(
~funktNANO = NanoKONTROL();

~funktbufs = "/Users/alo/sounds/mikrofunkt/*".pathMatch.collect({|path|
	Buffer.read(Server.default, path)
});

~glitchbufs = "/Users/alo/sounds/fb/*".pathMatch.collect({|path|
	Buffer.readChannel(Server.default, path, 0, 44100, [0])
});

~funktBus = Bus.audio(Server.default, 4);

~decoder = FoaDecoder(
	decoderType: 'quad'
);

//~decoder = Decoder(
//	isLocal: true, 
//	isUHJ: false,
//	speakersAzimuth: Array.series(3, 0.1667, 0.333).mirror2 * (pi.neg.dup(3) ++ pi.dup(3)),
//	speakersElevation: (0 ! 6)
//);

//// LIVE INPUT
~input = MikroInput(~decoder, thruBus: ~funktBus);

//// SATOSHI SAMPLES
//~input = MikroInput(~decoder, "/Users/alo/sounds/eclambone_samples/*");

//// CHRISTIAN
//~input = MikroInput(~decoder, "/Users/alo/sounds/christian/monoclipmx.aif");

~nCoef = 12;
~dur = 130;
~isMono = false;

~bpm = 135;
~beatdur = (~bpm / 60).reciprocal;
~round = ~beatdur / 8;

~analyzer = MikroAnalyzer(
	maxdur: ~dur, 
	numcoef: ~nCoef, 
	recordInput: true, 
	isMono: ~isMono
);

~graphics = MikroGraphics(
	width: 1024,
	height: 768,
	sizeX: 33,
	sizeY: 25,
	frameRate: 24,
	remoteAddr: NetAddr("127.0.0.1", 7770),
	vectorSize: ~nCoef,
	trainDur: 5000,
	lRate: 0.1
);

~mikro = Mikro(
	input: ~input,
	graphics: ~graphics,
	analyzer: ~analyzer
);

~mikro.addInitFunc({"/Users/alo/Development/mikro/audio/funkt.scd".load});
~mikro.addCleanFunc({"/Users/alo/Development/mikro/audio/funktcleanup.scd".load});

~procs = "/Users/alo/Development/mikro/audio/procs.scd".load;

~composer = MikroComposer(~mikro, ~procs);

~eq = MasterEQ(4);

~recognizer = PatchRecognizer(~mikro).load("/Users/alo/Data/mikro/110802_112556.plib");

~mikro.makeGui(~composer, ~recognizer);

)