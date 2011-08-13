(
~decoder = Decoder(
	isLocal: true, 
	isUHJ: true
);

~nCoef = 12;
~dur = 10 * 60;

~bpm = 135;
~beatdur = (~bpm / 60).reciprocal;
~round = ~beatdur / 8;

~graphics = MikroGraphics(
	width: 800,
	height: 600,
	sizeX: 40,
	sizeY: 40,
	frameRate: 18,
	remoteAddr: NetAddr("127.0.0.1", 7770),
	vectorSize: ~nCoef,
	trainDur: 5000,
	lRate: 0.1
);

~mikro = Mikro(
	liveInput: false,
	decoder: ~decoder,
	graphics: ~graphics,
	duration: ~dur,
	nCoef: ~nCoef
);

~analyzer = ~mikro.analyzer;

~composer = MikroComposer(~mikro);

~eq = MasterEQ(4);

~recognizer = PatchRecognizer(~mikro).load("/Users/alo/Data/mikro/110802_112556.plib");

~procs = "/Users/alo/Development/mikro/audio/procs.scd".load;

~mikro.makeGui(~composer, ~recognizer, ~procs);

)

~mikro.graphics.start(1)

~mikro.graphics.quit

~mikro.analyzer.events.size

~graphics.states




(
~scbackup = NetAddr("127.0.0.1", 57121)

~scbackup.sendMsg("/mikro/backup", 1) // start BACKUP synth
)
