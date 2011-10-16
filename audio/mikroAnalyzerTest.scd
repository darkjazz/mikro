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
//a.offAction = {|time, re, analyzer|  
//	Routine({
//		1.wait;
//		{PlayBuf.ar(1, analyzer.events.last.buffer, doneAction: 2).dup}.play
//	}).play
//}
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

a.events.do({|ev|
	[ev.start, ev.duration, ev.amps.size, ev.mfcs.size].postln
})



~intervals = Pseq(a.selectIntervals(0.05, 3).round((140/60).reciprocal), 1).asStream;
{
a.events.do({|ev|
	var amp, frq;
	frq = ev.frqs.collect(_.last).mean;
	amp = ev.amps.collect(_.last).mean;
	{
			BPF.ar(LFNoise0.ar(frq), frq, 10/frq, 10).dup 
				* EnvGen.kr(ev.ampsToEnv(8, 'sine', true, true), 
					timeScale: ev.duration, doneAction: 2)
	}.play;
	~intervals.next.wait;
})
}.fork

{
a.events.do({|ev|
	var amp, frq;
	frq = ev.frqs.collect(_.last).mean;
	amp = ev.amps.collect(_.last).mean;
	{
			BPF.ar(LFNoise0.ar(frq), frq, 10/frq, 10) 
				* XLine.kr(1.0, 0.001, ev.duration.linlin(0, 10, 0), doneAction: 2)
	}.play;
	~intervals.next.wait;
})
}.fork


a.events.do({|ev|
	var avg, std;
	avg = ev.frqs.collect(_.last).mean;
	std = 0;
	ev.frqs.do({|frq|
		std = std + pow(avg - frq.last, 2); 
	});
	std = (std / pow(ev.frqs.size, 2)).sqrt;
	[ev.start, avg, std].postln
})

{
	16.do({
		a.events.do({|ev|
			var frq = ev.frqs.collect(_.last).mean;
			{SinOsc.ar(frq).dup * XLine.kr(0.5, 0.001, 0.25, doneAction: 2)}.play;
			0.25.wait;
		})
	})
}.fork


a.events.do({|ev|
	ev.start.postln;
	ev.frqs.do(_.postln);
	"------------".postln;
})

a.events.first.ampsToEnv(10, 'sine').plot

a.events[2].ampsToEnv(10, 'sine').plot

a.visualize

x = MikroAnalyzer()

x.loadEvents("/Users/alo/Data/mikro/110329_135939.events")


x.events

a.events.do({|ev| ev.soms.do(_.postln); "----".postln })

x.events[2].amps.size

x.visualize

-40.dbamp