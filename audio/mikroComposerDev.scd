~liveprocs = "/Users/alo/Development/mikro/audio/mikroPROClive.scd".load;
~bufprocs = "/Users/alo/Development/mikro/audio/mikroPROCbuf.scd".load;

e = Array.fill(10, { Array.rand(8*4, 0, 3) });

z = e.collect({|chrm|
	chrm.clump(4).collect({|gn| gn.convertDigits(4).reciprocal })
})

z.do({|levels|
	Env(levels.normalize, levels.lastIndex.reciprocal ! levels.lastIndex, \sine).plot
})

