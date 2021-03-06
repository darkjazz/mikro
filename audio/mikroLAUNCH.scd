(
~decoder = FoaDecoder(
	isLocal: true, 
	decoderType: 'stereo'
);

//// LIVE INPUT
//~input = MikroInput(~decoder);

//// SATOSHI SAMPLES
~input = MikroFoaInput(~decoder, "/Users/alo/sounds/eclambone_samples/*");

//// CHRISTIAN
//~input = MikroInput(~decoder, "/Users/alo/sounds/christian/monoclipmx.aif");

~nCoef = 12;
~dur = 130;
~isMono = true;

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
	width: 800,
	height: 600,
	sizeX: 40,
	sizeY: 40,
	frameRate: 36,
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

~recognizer = PatchRecognizer(~mikro).load("/Users/alo/Data/mikro/110802_112556.plib");

~recognizer.addResponderFunction(\resp, {|rec|	
	Post << "Current patch: " << ~input.currentPatch << "  Current guess: " << rec.currentGuess << "  Most common: " << rec.mostCommon << Char.nl;
});

~procs = "/Users/alo/Development/mikro/audio/procs.scd".load;

~composer = MikroComposer(~mikro, ~procs);

~eq = MasterEQ(4);

~mikro.makeGui(~composer, ~recognizer);

)

~recognizer.run

~recognizer.removeResponderFunction(\resp)

~recognizer.stop

~mikro.graphics.start(1)

~mikro.graphics.quit

~graphics.states

~mikro.analyzer.visualize

~mikro.analyzer.elapsedTime

~mikro.analyzer.events.size


(
~scbackup = NetAddr("127.0.0.1", 57121)

~scbackup.sendMsg("/mikro/backup", 1) // start BACKUP synth
)
