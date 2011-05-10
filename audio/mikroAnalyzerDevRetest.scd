(

~buffer = Buffer.read(s,"/Users/alo/Music/SuperCollider Recordings/mikroInput_110509_210259.aif");
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

a.free

l = a.events[2].amps.collect(_.at(1)).clump(9).collect(_.mean)

a.events[3].duration

a.events.do({|ev| ev.amps.size.postln })

l = a.events[1].amps.collect(_.at(1))
Env([0.0] ++ l ++ [0.0], (l.size+1).reciprocal ! (l.size+1), \sine).plot
a.visualize