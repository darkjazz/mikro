(

~buffer = Buffer.read(s,thisProcess.platform.recordingsDir ++ "/mikroInput_110518_172904.aif");
//~buffer = Buffer.readChannel(s,"/Users/alo/sounds/christian/clip3.aif", channels: [0]);
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
//a.offAction = {|event|  
//	Routine({
//		1.wait;
//		{PlayBuf.ar(1, event.buffer, doneAction: 2).dup}.play
//	}).play
//}
)

a.events.size
a.events.do({|ev, i| [i, ev.duration].postln })
a.elapsedTime/60
a.events.select({|ev| ev.duration > 30 }).do({|ev| [ev.start, ev.duration].postln })

.do({|ev| ev.duration })

a.events.select({|ev| ev.amps.size < 3 }).do({|ev| ev.duration })

z=a.events.reject({|ev| (ev.duration < 0.1).or(ev.duration > 10.0) })

z[0].ampsToEnv(12, 'sine', true).plot
z[0].duration
z[3].amps.do({|ar, i|
	(ar[1] < -80.dbamp).postln
})

a.events.collect(_.duration).sum / a.events.size



a.free

l = a.events[2].amps.collect(_.at(1)).clump(9).collect(_.mean)

a.events[18].start

a.events.do({|ev| ev.amps.size.postln })

l = a.events[1].amps.collect(_.at(1))
Env([0.0] ++ l ++ [0.0], (l.size+1).reciprocal ! (l.size+1), \sine).plot
a.visualize

a.saveEvents
60, 114

a.events[114].buffer.write("/Users/alo/Desktop/wtf2.aif")


