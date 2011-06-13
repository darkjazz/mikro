~procs = "/Users/alo/Development/mikro/audio/mikroPROCsynth.scd".load

~mikro.decoder.start

~ev = ~mikro.analyzer.events.choose;
~ev.duration

~mikro.analyzer.events.size
~ev.ampsToEnv(8, '\sine', true, true).plot

Routine({
	~mikro.analyzer.events.do({|ev|
		~composer.startBufSynth(\bufmod, ev.ampsToEnv(8, '\sine', true, true), ev.buffer, 
			ev.buffer, ev.duration, 1
		);
		ev.duration.wait;
	});
	"done".postln	
}).play


Routine({
	~mikro.analyzer.events.do({|ev|
		{PlayBuf.ar(1, ev.buffer, doneAction: 2)}.play;
		ev.duration.wait	
	})
}).play

~synth = Synth.before(~decoder.synth, \clck, 
	[\ou, ~decoder.bus, \ef, 99, \fr, 20000, \dr, 3, \xa, 0, \ya, 0, \za, 0, \ea, 1, \am, 100, \bt, 8 ])
	.setn(\env, ~ev.ampsToEnv(8, '\sine', true, true).asArray)
	.setn(\delay, Array.geom(4, 0.008, 1.618))
	.setn(\amp, Array.geom(4, 1.0, 0.918))

~procs[\kck]

~mikro.analyzer.events