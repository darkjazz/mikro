(
~decoder = FoaDecoder(
	isLocal: true, 
	decoderType: 'stereo'
);

//// SATOSHI SAMPLES
~input = MikroFoaInput(~decoder, "/Users/alo/sounds/eclambone_samples/*");

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
	sizeX: 32,
	sizeY: 32,
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

~recognizer = PatchRecognizer(~mikro, 30).load("/Users/alo/Data/mikro/110802_112556.plib");

~procs = "/Users/alo/Development/mikro/audio/procs.scd".load;

~composer = MikroComposer(~mikro, ~procs, ~recognizer);

~eq = MasterEQ(4);

~mikro.makeGui(~composer, ~recognizer);

)







	SynthDef(\arhythmic, {|out, in, gate = 1, drB=0.125, amp=0.5, th=0.01, quant=0.25|
		var sig, trigs, fft, beat, env, input, sB, pch, ampctr, bfft;
		var af, bf, trigB;
		input = In.ar(in);
		env = EnvControl.kr;
		pch = Tartini.kr(input).first;
		fft = FFT(LocalBuf(1024), input);
		ampctr = Lag.kr(Amplitude.kr(input), 0.25);
		trigB = Trig.kr(Onsets.kr(fft, th), quant);
		sB = Gendy3.ar(2, 5, 0.5, 0.5, pch, 0.25, 0.25, 21, 21)
			* EnvGen.kr(Env([1, 1, 0], [0.25, 0.75], \sine), trigB, timeScale: drB);
		sB = GVerb.ar(sB*input, LFSaw.kr(LFSaw.kr(1).range(0.5, 2)).range(4, 20), 
			Latch.kr(ampctr, trigB)).first;
		sB = DelayN.ar(CombC.ar(sB, 0.25, 0.25, 1), 0.5, LFSaw.kr(1.5).range(0.0625, 0.5).round(0.0625));
		bfft = FFT(LocalBuf(1024), Normalizer.ar(sB, -6.dbamp) * amp);
		af = Array.fill(4, { IFFT(PV_Diffuser(bfft, trigB)) });
		bf = FoaEncode.ar(af, FoaEncoderMatrix.newAtoB);
		Out.ar(out, FoaTransform.ar(bf, 'rtt', 
			TRand.kr(pi, -pi, trigB), 
			TRand.kr(pi, -pi, trigB), 
			TRand.kr(pi, -pi, trigB)) * EnvGen.kr(env, gate, doneAction: 2)
		);
	}, metadata: (
			type: \live, activeIndex: 2, maxweight: 0.2, mindur: 5.0, fadetime: 2.0,
			specs: (
				drB: ControlSpec(0.0625, 0.25, step: 0.0625),
				th: ControlSpec(-40.dbamp, -10.dbamp, default: -40.dbamp),
				quant: ControlSpec(0.0625, 1.0, step: 0.0625, default: 0.25),
				amp: ControlSpec(0.2, 0.5)
			)		
		)
	)

