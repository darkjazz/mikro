(
~buffers = Array();
"/Users/alo/sounds/eclambone_samples/*".pathMatch.do({|path|
	~buffers = ~buffers.add(Buffer.read(s, path))
});

SynthDef(\playPatch, {|out, buf, amp|
	var sig;
	sig = PlayBuf.ar(1, buf, loop: 0, doneAction: 2);
	Out.ar(out, sig);
	Out.ar(0, sig.dup * amp)
}).add;

)

//~somBuffer = Buffer.read(s, "/Users/alo/Data/mikro/somData_110403_113759_TD10000NC8ND2SZ40.aif");
~dur = 60;
//~analyzer = MikroAnalyzer(~dur, traindur: 5000, somBuffer: ~somBuffer);
~analyzer = MikroAnalyzer(~dur);


(
///ANALYZER
~bus = Bus.audio(s);
~analyzer.start(~bus, 1, \addToTail, -80.dbamp, 0.05, 20);
SystemClock.sched(0.2, {
	~currentBuf = ~bufs.next;
	if (~currentBuf.isNil) { 
		~bufs = Pseq(~buffers.scramble, 1).asStream; 
		~currentBuf = ~bufs.next;	
	};
	~currentBuf.postln;
	~analyzer.elapsedTime.postln;
 	Synth.before(~analyzer.synth, \playPatch, [\out, ~bus, \buf, ~currentBuf, \amp, 0]); 
 	if ((~dur - ~currentBuf.duration) > ~analyzer.elapsedTime ) { ~currentBuf.duration } { nil };

})

)

~analyzer.free

~analyzer.events.size

~analyzer.events.do({|ev| [ev.duration, ev.amps.size, ev.duration / ev.amps.size].postln })


p = Pseq((0..~analyzer.events.lastIndex), 1).asStream

~analyzer.events[p.next].ampsToEnv(8, 'sine').plot

~analyzer.visualize

e = ~analyzer.events[0].mfcs

e.levels

(
Routine({
	var delta = ~analyzer.events.first.start;
	~analyzer.events.do({|event, i|
		delta.wait;
		event.buffer.postln;
		{PlayBuf.ar(1, event.buffer, doneAction: 2).dup}.play;
		if (i != ~analyzer.events.lastIndex)
		{
			delta = ~analyzer.events[i+1].start - event.start;
		}
		
	})
}).play
)

~analyzer.events.do({|ev|
	[ev.duration, ev.amps.size].postln;
//	ev.amps.postln;
//	"--------------".postln
})



~analyzer.loadEvents("/Users/alo/Data/mikro/110403_122248.events")

~analyzer.events.size

~analyzer.events.do({|ev| ev.mfcs.postln })

~analyzer.events[2].amps.do(_.postln)

~analyzer.events[0].amps

~analyzer.events[116].amps.do({|amp|
	(amp.last.abs.explin(0.001, 1.0, 0.1, 1.0)).postln
})

e = ~analyzer.events[116].amps.collect({|amp| amp.last.abs.explin(0.001, 1.0, 0.1, 1.0) })


~analyzer.saveEvents

~analyzer.visualize

~analyzer.elapsedTime


s.queryAllNodes

~analyzer.somError

~analyzer.writeSOMBuffer

e = Env()
e.plot

Routine({
	~analyzer.events.do({|ev|
		plot
	})
})


(
///SOM TRAIN

if (~bus.isNil) { ~bus = Bus.audio(s) };
~analyzer.startSOMTrain(~bus, 1, \addToTail, msgrate: 10);

SystemClock.sched(1, {
	~currentBuf = ~bufs.next;
	if (~currentBuf.isNil) { 
		~bufs = Pseq(~buffers.scramble, 1).asStream; 
		~currentBuf = ~bufs.next;	
	};
 	Synth.before(~analyzer.synth, \playPatch, [\out, ~bus, \buf, ~currentBuf, \amp, 0]); 
 	[~analyzer.somRemaining, ~analyzer.somError].postln;
 	if (~analyzer.somRemaining > 0 ) { ~currentBuf.duration } { nil };

})

)

~analyzer.showSOM(15);

{
	var fft, sig = LFNoise2.ar( LFNoise2.kr(1, 700, 800), LFNoise2.kr(2, 0.5, 0.5) );
	fft = FFT(LocalBuf(1024), sig);
//	SpecCentroid.kr(fft).poll(4);
//	Loudness.kr(fft).poll(4);
//	Amplitude.kr(sig).poll(4);
}.play