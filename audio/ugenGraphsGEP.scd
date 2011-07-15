//~ar = UGen.subclasses.select(_.respondsTo('ar'));

//~ar = ~ar ++ ~ar.select({|class| class.subclasses.notNil }).collect({|class| class.subclasses }).flat;
//~ar.do(_.postln)
(
~ar = [\SinOsc, \LFSaw, \VarSaw, \LFNoise0, \Dust2, \FreeVerb, \WhiteNoise, \DelayN].collect({|name| 
	UGen.subclasses.select({|class| class.name == name }).first
});

~chrs = Array.fill(20, {|i|
	[~ar.choose.name] ++ Array.fill(23, {
		[~ar.choose.name, "d", "f"].choose
	}) ++ Array.fill(8, { ["d", "f"].choose })
});

~chrs.do({|chr|
	chr.postln;
	"  ".postln;
});

~translate = {|ugen, chr, index, depth = 1|
	var args, argEnvir, argNames, str = "";
	("UGEN: " ++ ugen).postln;
	if (ugen.class.methods.notNil)
	{
		if (ugen.class.methods.select({|mth| mth.name == 'ar' }).size > 0) 
		{
			argNames = ugen.class.methods.select({|mth| mth.name == 'ar' }).first.argNames
		}
		{
			argNames = ugen.superclass.class.methods.select({|mth| mth.name == 'ar' }).first.argNames
		}
	}
	{
		argNames = ugen.superclass.class.methods.select({|mth| mth.name == 'ar' }).first.argNames
	};
	argNames = argNames.drop(1);
	argNames.postln;
	args = chr[index..(index+argNames.size-1)];
	args.postln;
	if (ugen.class.methods.notNil)
	{
		if (ugen.class.methods.select({|mth| mth.name == 'ar' }).size > 0)
		{
			argEnvir = ugen.class.methods.select({|mth| mth.name == 'ar' }).first.makeEnvirFromArgs;
		}
		{
			argEnvir = ugen.superclass.class.methods.select({|mth| mth.name == 'ar' }).first.makeEnvirFromArgs;
		}
	}
	{
		argEnvir = ugen.superclass.class.methods.select({|mth| mth.name == 'ar' }).first.makeEnvirFromArgs;
	};
	argEnvir.postln;
	index = index+args.size;
	args.do({|item, i|
		if (item.isKindOf(Symbol)) {
			ugen = ~ar.select({|class| class.name == item }).first;
			str = str ++ argNames[i].asString ++ ": " ++ ugen.name.asString ++ ".ar(" ++ ~translate.value(ugen, chr, index, depth + 1) ++ ")";
		}
		{
			if (item == "d") {
				str = str ++ argNames[i].asString ++ ": " ++ (argEnvir[argNames[i]] ? 0.0).asString;
			}
			{
				str = str ++ argNames[i].asString ++ ": " ++ (argEnvir[argNames[i]] ? 0.0 * rrand(0.1, 10.0)).asString;
			};
						
		};
		if (i < args.lastIndex) { str = str ++ ", " }
		
	});
	str
};

~codestrings = ~chrs.collect({|chr|
	var str, class;
	"----------------".postln;
	str = "{";
	str = str ++ chr[0].asString ++ ".ar(";
	class = ~ar.select({|cls| cls.name == chr.first }).first;
	str = str ++ ~translate.value(class, chr, 1);
	str = str ++ ")}"	
});

)

~codestrings.do({|str|
	str.postln;
	"------".postln;
	".postln"
})


~codestrings.do({|str|
	~result = str.compile;
	try {~result.asSynthDef.add} {|error| [\yo, error].postln }
});

