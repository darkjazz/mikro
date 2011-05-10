(

~buffer = Buffer.read(s, "/Users/alo/sounds/eclamseq.aif");
~bus = Bus.audio(s);

SynthDef(\input, {|out, buf|
	var sig;
	sig = PlayBuf.ar(1, buf, doneAction: 2);
	Out.ar(out, sig)
}).add;
)

a = MikroAnalyzer(~buffer.duration);

(
z = Synth(\input, [\out, ~bus, \buf, ~buffer]);
a.start(~bus, z, \addAfter, -80.dbamp, 0.05, 30);
a.offAction = {|event|  
	Routine({
		1.wait;
		{PlayBuf.ar(1, event.buffer, doneAction: 2).dup}.play
	}).play
}
)

Routine({
	var delta = ~analyzer.events.first.start;
	a.events.do({|event, i|
		delta.wait;
		event.buffer.postln;
		{PlayBuf.ar(1, event.buffer, doneAction: 2).dup}.play;
		if (i != a.events.lastIndex)
		{
			delta = a.events[i+1].start - event.start;
		}
		
	})
}).play

a.offAction = nil

a.free

a.saveEvents

a.events.size

e.do({|ev|
	[ev.start, ev.duration, ev.amps.size].postln
})

a.visualize

x = MikroAnalyzer()

x.loadEvents("/Users/alo/Data/mikro/110329_135939.events")


x.events

a.events.do({|ev| ev.soms.do(_.postln); "----".postln })

x.events[2].amps.size

x.visualize

-40.dbamp