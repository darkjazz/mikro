(
~decoder = Decoder(
	isLocal: true, 
	isUHJ: true
);

~nCoef = 12;
~dur = 6 * 60;

~graphics = MikroGraphics(
	width: 800,
	height: 600,
	sizeX: 30,
	sizeY: 30,
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

~composer = MikroComposer(~mikro);

~eq = MasterEQ(4);

~recognizer = PatchRecognizer(~mikro).load("/Users/alo/Data/mikro/110802_112556.plib");

~procs = "/Users/alo/Development/mikro/audio/procs.scd".load;
	
~mikro.makeGui(~composer, ~recognizer, ~procs);

);

~mikro.analyzer.events.size

~mikro.analyzer.visualize

~mikro.initPerformance;

(
~graphics.settings[\transz] = 40;
~graphics.settings[\transx] = -40;
~graphics.settings[\transy] = -12;
~graphics.settings[\groupx] = 5;
~graphics.settings[\groupy] = 5;

~graphics.sendSettings
)

~mikro.start(-40.dbamp, 0.1, 30);

(
~ind = Pseq((0..15), inf).asStream;

~def = \cliq;
~id = ~composer.play(~def, Env([0.001, 1.0, 1.0, 0.001], [0.3, 0.4, 0.3], \sine, 2, 1), 
	Pseq(~graphics.states, 1).asStream);

~composer.mapStates(~id, ~composer.descLib[~def].metadata.specs.collect({ ~ind.next }) );
)

~composer.releaseSynth(~id, 1)

~composer.releaseSynth(1010, 5)

~mikro.quit

~graphics.quit

s.queryAllNodes

~mikro.testBuffers

~graphics.states.size

~mikro.analyzer.events.do({|ev| [ev.start, ev.duration].postln })



/// SILENT TEST

(


~buffer = Buffer.read(s, "/Users/alo/sounds/christian/monoclip1.aif");
~bus = Bus.audio(s);

SynthDef(\input, {|out, buf|
	var sig;
	sig = PlayBuf.ar(1, buf, doneAction: 2);
	Out.ar(out, sig)
}).add;

)

a = MikroAnalyzer(~buffer.duration, isMono: false);

(
~insynth = Synth(\input, [\out, ~bus, \buf, ~buffer]);
a.start(~bus, ~insynth, \addAfter, -5.dbamp, 0.1, 30);
)

a.free

a.events.size

a.elapsedTime

a.events.do({|ev|
	[ev.start, ev.duration, ev.amps.size, ev.mfcs.size].postln
})


Routine({
	a.events.do({|event, i|
		event.buffer.postln;
		{PlayBuf.ar(1, event.buffer, doneAction: 2).dup}.play;
		event.duration.wait;		
	})
}).play


Routine({
	a.events.do({|event, i|
		var frq;
		frq = event.frqs.collect(_.at(1)).mean;
		{Dust2.ar(frq).dup * EnvGen.kr(Env([0, 1, 1, 0], [0, 0.05, 0]), doneAction: 2)}.play;
		event.duration.wait;		
	})	
}).play

m=a.eventIntervals.mean;
d=a.eventIntervals.stdDev;
~sInd = Array();
a.eventIntervals.do({|intv, i|
	if (intv > (m + d)) { ~sInd = ~sInd.add(i) }
})

~sInd