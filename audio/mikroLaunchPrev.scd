~composer.bufProcs.keys(Array).choose

~composer.intervals

~mikro.analyzer.events.size

~mikro.analyzer.elapsedTime

~mikro.graphics.fadeInPattern(1, 0.5, 10);


~mikro.graphics.sendSetting(\add, 0.005)

~mikro.graphics.fadeInPattern(0, 1.0, 10);

~mikro.graphics.fadeOutPattern(5, 10)

~mikro.analyzer.onsetAction = nil

~mikro.graphics.quit;


~mikro.analyzer.visualize

.do({|ev, i| [i, ev.duration].postln })

(
	~ev = ~mikro.analyzer.events.choose;
	[~ev.duration, ~ev.amps.size].postln;
	~composer.startSynthSynth(
		\snr, 
		~ev.ampsToEnv(8, '\sine', true, true), 
		~ev.duration, 
		~ev.frqs.choose.last, 
		Pseq(~mikro.graphics.states, inf).asStream
	)
)

(
	~ev = ~mikro.analyzer.events.choose;
	[~ev.duration, ~ev.amps.size].postln;
	~env = ~ev.ampsToEnv(8, '\sine', true, true);
	~composer.startBufSynth(
		\bufmod, 
		Env(~env.times, [0.05, 1, 0.05], \sine, 2, 1), 
		~ev.buffer,
		~mikro.analyzer.events.choose.buffer,
		5, 
		1,
		Pseq(~mikro.graphics.states, inf).asStream
	)
)

(
	~ev = ~mikro.analyzer.events.choose;
	[~ev.duration, ~ev.amps.size].postln;
	~env = ~ev.ampsToEnv(8, '\sine', false, true);
	~composer.startSynthSynth(
		\clck, 
		if (~env.times.size < 6) { Env.perc } { ~env }, 
		if (~ev.duration < 0.5) { ~ev.duration * 10 } { ~ev.duration }, 
		~ev.frqs.choose.last,
		Pseq(~mikro.graphics.states, inf).asStream
	)
)

s.sendMsg("/n_free", 1256)


~composer.synthProcs['nzsnr'].specs =(
	am: ControlSpec(10, 20),
	xa: ControlSpec(-pi, pi),
	ya: ControlSpec(-pi, pi),
	za: ControlSpec(-pi, pi)
)

~composer.synthProcs['gndy'] = (
		def: SynthDef(\gndy, {|ou, dr, fr, sf, ef, xa, ya, za, am|
			var sig, w, x, y, z, del, amp;
			del = ArrayControl.kr(\delay, 4, 1);
			amp = ArrayControl.kr(\amp, 4, 1);		
			sig = BPF.ar(Gendy3.ar(freq: XLine.kr(sf, ef, dr)), fr, 10 / fr, 10)
				* EnvGen.kr(EnvControl.kr(size: 12), timeScale: dr, doneAction: 2);
			#w, x, y, z = A2B.ar(*Array.fill(4, {|i|
				DelayC.ar(sig, 0.1, del[i], amp[i])
			}));
			Out.ar(ou, AtkRotateXYZ.ar(w, x, y, z, xa, ya, za) * am)
		}).add,
		
		specs: (
			ef: ControlSpec(400, 800, step: 2**(1/5)),
			sf: ControlSpec(200, 300, step: 2**(1/12)),
			am: ControlSpec(1.0, 2.0),
			xa: ControlSpec(-pi, pi),
			ya: ControlSpec(-pi, pi),
			za: ControlSpec(-pi, pi)
		),
		
		array: (
			delay: Array.geom(4, 0.008, 1.618),
			amp: Array.geom(4, 1.0, 0.918)
		)

	)
~mikro.decoder.start

~composer.activeSynthSynths

~mikro.initPerformance();

~composer.intervals.dict.keys.choose

MasterEQ(2)
~mikro.freeInput

(
	~ev = ~mikro.analyzer.events.choose;
	~composer.startSynthSynth(
		\kck, 
		~ev.ampsToEnv(8, '\sine', true), 
		~ev.duration, 
		~ev.frqs.choose, 
		Pseq(~mikro.graphics.states, inf).asStream
	)
)



~mikro.stop




~composer.freeSynth(1125, 10)

~composer.activeLiveSynths['1004'].set("i_wrp", 0.1)

~mikro.graphics.putStatesFunction(\states, {|states|
	states.postln
})
~mikro.graphics.removeStatesFunction(\states)

~mikro.makeGui

~mikro.analyzer.events.last.buffer


~mikro.analyzer.events.do({|ev| [ev.duration, ev.buffer.numFrames/ev.buffer.sampleRate].postln })

~mikro.graphics.sendPattern(0, 1, 1)

~mikro.graphics.sendPattern(0, 0, 1)

~mikro.graphics.sendMsg("settings", 0.1)

~mikro.graphics.start

(
r = Routine({
	
	inf.do({
		var arr = Array.rand(8, 0.0, 1.0);
		~mikro.graphics.sendWeights(*arr);
		0.1.wait;
	});
	
}).play
)


~mikro.graphics.sendPattern(6, 1, 0.5)

~mikro.graphics.fadeInPattern(7, 1, 10)

~mikro.graphics.fadeOutPattern(7, 10)


~mikro.graphics.sendSetting(\transx, -8.0)

~mikro.graphics.start(1)

(
r.stop
)
~mikro.graphics.collectSettings
~mikro.stop
~mikro.analyzer.free

~mikro.freeInput

~mikro.decoder.free

p = "/Users/alo/Development/mikro/audio/mikroPROCsynth.scd".load;

p.keysValuesDo({|key, val|
	val.def.add
})


~min = 20;
~max = 160;

~frq = 2365;

f = {|val, min, max, depth = 1|
	if (val > max) { val = f.value(val / 2, min, max, depth + 1) };
	if (val < min) { val = f.value(val * 2, min, max, depth + 1) };
	if (depth > 6) { val = max + min / 2 };
	val
}

f.value(~frq, ~min, ~max)