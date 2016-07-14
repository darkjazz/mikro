(
~analyzer = MikroAnalyzer(60, 12, true);

~bpm = 140;
~bps = ~bpm / 60;

~quant = ~bps.reciprocal / 8;

)

~analyzer.loadEvents("/Users/alo/Data/mikro/110719_103915.events")


~analyzer.events.do({|ev|
	[ev.start, ev.duration, ev.start + ev.duration].postln
})

~analyzer.eventIntervals

e = 
~analyzer.events[0].ampsToEnv(8, 'sine', true, true, false, -80.dbamp).plot

l = e.amps.collect(_.at(1))

l = l.clump((l.size / 8).floor).collect(_.mean)

~events = ~analyzer.selectEvents.collect({|ev|
	(
		dur: ev.duration.round(~quant),
		start: ev.start.round(~quant),
		levels: ev.ampsToEnv(8, 'lin', true, true, true, -60.dbamp).levels
	)
});

~population = ~events.keep(32).clump(8);

~intr = ~analyzer.eventIntervals.round(~quant)

~intr.do({|intr, i|
	[i, (intr / ~bps.reciprocal)].postln
})

~analyzer.selectEvents.size

)

~mikro.analyzer.events.do({|ev|
	[ev.start, ev.duration].postln
})
