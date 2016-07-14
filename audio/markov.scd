~analyzer.events.size

~analyzer.events.do({|ev|
	[ev.start, ev.duration, ev.amps.size, ev.amps.collect(_.last).maxItem + 0.01 ** 0.5].postln
})

~analyzer.visualize

~intervals = MarkovSet();

~analyzer.eventIntervals.doAdjacentPairs({|a, b|
	~intervals.read(a.round(0.001), b.round(0.001))
});

~events = MarkovSet();

~analyzer.events.doAdjacentPairs({|a, b| 
	~events.read(a.duration.round(0.001), b.duration.round(0.001))
})

~amps = MarkovSet();
~analyzer.events.doAdjacentPairs({|a, b| 
	var ampa, ampb;
	ampa = a.amps.collect(_.last).maxItem + 0.01 ** 0.5;
	ampb = b.amps.collect(_.last).maxItem + 0.01 ** 0.5;
	~amps.read(ampa.round(0.01), ampb.round(0.01))
})


~intervals.dict.size
~events.dict.size
~amps.dict.size

o = ~intervals.dict.keys.choose
d = ~events.dict.keys.choose
a = ~amps.dict.keys.choose

~findEvent = {|dur|
	~analyzer.events.select({|ev| 
		(ev.duration > (d * 0.9)).and(ev.duration < (d * 1.1)) 
	}).scramble.first;
};

~events.dict.keysDo({|key|
	~findEvent.(key).buffer.postln	
})

r = Routine({
	inf.do({
		{PlayBuf.ar(1, ~findEvent.(d).buffer).dup * XLine.kr(1.0, 0.001, d, doneAction: 2).dup}.play;
		Post << "duration: " << d << " -- amp: " << a << " -- interval: " << o << Char.nl;
		o = ~intervals.next(o);
		d = ~events.next(d);
		a = ~amps.next(a);
		o.wait;
	})
}).play

r.stop