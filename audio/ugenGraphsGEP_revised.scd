~ar = UGen.subclasses.select(_.respondsTo('ar'));

~ar = ~ar ++ ~ar.select({|class| class.subclasses.notNil }).collect({|class| class.subclasses }).flat;

~chrs = Array.fill(100, {|i|
	[~ar.choose] ++ Array.fill(23, {
		[~ar.choose, "d", "f"].choose
	}) ++ Array.fill(8, { ["d", "f"].choose })
});

~chrs.do({|chr|
	chr.postln;
	"  ".postln;
});


(
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
		if (item.isKindOf(Class)) {
			str = str ++ argNames[i].asString ++ ": " ++ ugen.name.asString ++ ".ar(" ++ ~translate.value(item, chr, index, depth + 1) ++ ")";
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
)

~codestrings = ~chrs.collect({|chr|
	var str;
	"----------------".postln;
	str = "{";
	str = str ++ chr[0].asString ++ ".ar(";
	str = str ++ ~translate.value(chr.first, chr, 1);
	str = str ++ ")}"	
});


~codestrings.do({|str|
	str.postln;
	"------".postln;
	".postln"
})

~codestrings[0].postln

~codestrings.do({|str, i|
	
	~result = str.compile;
	try {~result.asSynthDef; Post << i << " SUCCESSFULLY COMPILED!!!!!!!!" << Char.nl;} 
	{|error| Post << i << " FAILED!!!!!" << Char.nl; }
})

