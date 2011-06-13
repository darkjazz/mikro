~ugens = [\SinOsc, \LFSaw, \VarSaw, \LFNoise0, \Dust2, \FreeVerb, \WhiteNoise, \DelayN].collect({|name| 
	UGen.subclasses.select({|class| class.name == name }).first
});

~gep = UGenGraphGEP(20, 32, ~ugens)

~gep.collectCodeStrings

~gep.population.do(_.postln)

f = ~gep.codeStrings.collect(_.compile)

~gep.codeStrings.collect(_.size)

~gep.codeStrings.do({|str|
	str.postln;
	"--------------".postln;
	"".postln
})

d = f.collect({|fnc, name|
	SynthDef(name, {|out, dur|
		var env, sig;
		env = EnvGen.kr(EnvControl.kr, timeScale: dur, doneAction: 2);
		sig = SynthDef.wrap(fnc) * env;
		Out.ar(out, sig)
	}).add
})

Routine({
	d.keysValuesDo({|key, def|
		Synth(key, [\out, 0, \dur, 0.3]).setn(\env, Env.perc);
		0.5.wait;
	})
}).play
