~ugens = [\SinOsc, \LFSaw, \VarSaw, \LFNoise0, \Dust2, \FreeVerb, \WhiteNoise, \DelayN].collect({|name| 
	UGen.subclasses.select({|class| class.name == name }).first
});

g = RedGAGenome(Array.fill(20, {[~ugens.choose, 1.0.rand].choose }))

g.chromosome

~gep = UGenGraphGEP(40, 32, ~ugens)
~gep = UGenGraphGEP(40, 32)

~gep

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


UGen.subclasses.select(_.respondsTo('ar')).select({|ugen|
	var hasInput;
	if (ugen.class.methods.select({|mth| mth.name == 'ar' }).size > 0)
	{
		hasInput = ugen.class.methods.select({|mth| mth.name == 'ar' }).first.argNames.indexOf('in').notNil 
	}
	{
		hasInput = ugen.superclass.methods.select({|mth| mth.name == 'ar' }).first.argNames.indexOf('in').notNil
	};
	hasInput
}).do({|ugen|
	Post << ugen.name << ": ";
	if (ugen.class.methods.select({|mth| mth.name == 'ar' }).size > 0)
	{
		ugen.class.methods.select({|mth| mth.name == 'ar' }).first.argNames.postln 
	}
	{
		ugen.superclass.methods.select({|mth| mth.name == 'ar' }).first.argNames.postln
	};	
});

MultiOutUGen.subclasses.select(_.respondsTo('ar')).select({|ugen|
	var hasBuffer;
	if (ugen.class.methods.select({|mth| mth.name == 'ar' }).size > 0)
	{
		hasBuffer = ugen.class.methods.select({|mth| mth.name == 'ar' }).first.argNames.indexOf('bufnum').notNil 
	}
	{
		hasBuffer = ugen.superclass.methods.select({|mth| mth.name == 'ar' }).first.argNames.indexOf('bufnum').notNil
	};
	hasBuffer
}).do({|ugen|
	Post << ugen.name << ": ";
	if (ugen.class.methods.select({|mth| mth.name == 'ar' }).size > 0)
	{
		ugen.class.methods.select({|mth| mth.name == 'ar' }).first.argNames.postln 
	}
	{
		ugen.superclass.methods.select({|mth| mth.name == 'ar' }).first.argNames.postln
	};	
})
