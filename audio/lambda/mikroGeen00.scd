// load data


s.loadDirectory("/Users/alo/Data/gep/synthdefs");

~metadata = UGenExpressionTree.loadMetadataFromDir.select({|data|
	data.stats.mfcc.size == 20 && data.stats.mfcc.collect(_.mean).sum.isNaN.not
});

(
// cluster synthdefs

~nclusters = 64;
~kmeans = KMeans(~nclusters);

~metadata.do({|data|
	~kmeans.add(data.stats.mfcc.collect(_.mean))
});

~kmeans.update
)


(
// classify
~eventClass = Array();

~analyzer.events.do({|ev, i|	
	~eventClass = ~eventClass.add(~kmeans.classify(ev.meanMFCC))
});

~eventData = Array();

~analyzer.events.do({|ev, i|
	var diff = 100, best;
	~kmeans.assignments.selectIndices({|ind| ind == ~eventClass[i] }).do({|dataindex|
		if (abs(ev.meanMFCC - ~kmeans.data[dataindex]).sum < diff) {
			diff = abs(ev.meanMFCC - ~kmeans.data[dataindex]).sum;
			best = dataindex
		}
	});
	~eventData = ~eventData.add( ~metadata[best] )
	
});

)

(

r=Routine({
	var vbuf, bus = Bus.audio(s, 2);
	s.record;
	SynthDef(\procgen, {|in, dur, amp|
		var env, input;
		env = EnvControl.kr(size: 16);
		input = In.ar(in, 2) * EnvGen.kr(env, timeScale: dur, levelScale: amp, doneAction: 3);
		Out.ar(0, input.clip(-0.9, 0.9))
	}).add;
	s.sync;
	~analyzer.events.do({|ev, i|
		var synth = Synth(~eventData[i].defname, [\out, bus] ++ ~eventData[i].args);
		Synth.after(synth, \procgen, [\in, bus, \dur, ev.duration * (3.rand+1), \amp, 0.8])
			.setn(\env, ev.ampsToEnv(8, 'sine', true, true, true));
		[i, ev.start, ~eventData[i].defname].postln;
		ev.duration.wait;
	});
	(~analyzer.events.last.duration * 3).wait;
	"sequence finished".postln;
	s.stopRecording;
}).play

)



~args = ~metadata.collect(_.args)

(
~data = MikroData().loadPathMatch

~durSet = MarkovSet();
~freqSet = MarkovSet();
~ampSet = MarkovSet();
~intSet = MarkovSet();
~clusterSet = MarkovSet();

~envSet = FuzzySet();

~timeQuant = (2**6).reciprocal;
~freqQuant = {|freq, octavediv=24, ref=440|
	2**(round(log2(freq/ref)*octavediv)/octavediv)*ref
};
)

(
~data.datalib.keysValuesDo({|key, data|
	var intervals = Array();
	data.events.doAdjacentPairs({|evA, evB|
		~durSet.read(*[evA.duration, evB.duration].round(~timeQuant));
		~freqSet.read(*~freqQuant.([evA.meanFreq, evB.meanFreq]));
		~ampSet.read(*[evA.peakAmp, evB.peakAmp].round(~timeQuant));
		~envSet.put(evA.duration.round(~timeQuant), evA.ampsToEnv(16, 'sine', true, true, true));
		~clusterSet.read( ~kmeans.classify(evA.meanMFCC), ~kmeans.classify(evB.meanMFCC) );
		intervals = intervals.add(evB.start - evA.start);
	});
	~envSet.put(data.events.last.duration.round(~timeQuant), data.events.last.ampsToEnv(16, 'sine', true, true, true));
	intervals.doAdjacentPairs({|intA, intB| ~intSet.read(*[intA, intB].round(~timeQuant))  });
});

)

~allEvents = ~data.datalib.values.collect(_.events).flat;

~source = ~allEvents.choose;



~currentEvent = (
	dur: ~source.duration.round(~timeQuant), 
	freq: ~freqQuant.(~source.meanFreq),
	amp: ~source.peakAmp.round(~timeQuant),
	env: ~envSet[~source.duration.round(~timeQuant)],
	cluster: ~kmeans.classify(~source.meanMFCC),
	int: ~intSet.dict.choose[0];
);


~sequence01 = 16.collect({
	~currentEvent = (
		dur: ~durSet.next(~currentEvent.dur), 
		freq: ~freqSet.next(~currentEvent.freq),
		amp: ~ampSet.next(~currentEvent.amp),
		env: ~envSet[~durSet.next(~currentEvent.dur)],
		cluster: ~clusterSet.next(~currentEvent.cluster),
		int: ~intSet.next(~currentEvent.int)
	)
})

~sequence01.do(_.postln)

~defnames.do({|arr| arr.postln })


(
~source = ~allEvents.choose;
~currentEvent = (
	dur: ~source.duration.round(~timeQuant), 
	freq: ~freqQuant.(~source.meanFreq),
	amp: ~source.peakAmp.round(~timeQuant),
	env: ~envSet[~source.duration.round(~timeQuant)],
	cluster: ~kmeans.classify(~source.meanMFCC),
	int: ~intSet.dict.choose[0];
);

~defclusters = ();

~clusterSet.dict.keys(Array).do({|num|
	~defclusters[num] = ~kmeans.assignments.selectIndices({|ind| num == ind })
});

~rout = Routine({
	SynthDef(\dynamics, {|in|
		var eq, input, sig;
		eq = (
			ugen: [BLowShelf, (BPeakEQ ! 3), BHiShelf].flat,
			freq: Array.geom(5, "c 3".notemidi.midicps, 3.6),
			bw: [0.65, 1, 3.5, 1.5, 1],
			db: [4, 0, -4, 2, 6]
		);
		input = In.ar(in, 2);
		sig = Mix.fill(5, {|i| eq.ugen[i].ar(input, eq.freq[i], eq.bw[i], eq.db[i]) });
		Out.ar(0, sig)
	}).add;
	SynthDef(\procgen, {|out, in, dur, amp|
		var env, input;
		env = EnvControl.kr(size: 16);
		input = In.ar(in, 2) * EnvGen.kr(env, timeScale: dur, levelScale: amp, doneAction: 3);
		Out.ar(out, input)
	}).add;
	s.sync;
	loop({
		var synth, defindex, data, bus, args;
		bus = Bus.audio
		defindex = ~metadata[~defclusters[~currentEvent.cluster].choose];
		data = ~metadata[defindex];
		args = data.args;
		args.selectIndices({|item| item > ~freqQuant.("c 0".notemidi.midicps) }).do({|argindex|
			args[argindex] = ~freqQuant.(args[argindex], 24, ~currentEvent.freq)
		});
		synth = Synth(data.defname, [\out, bus] ++ args);
		Synth.after(synth, \procgen, [\in, bus, \dur, ~currentEvent.dur, \amp, ~currentEvent.amp])
			.setn(\env, ~currentEvent.env);
		~currentEvent.int.wait;
		~currentEvent = (
			dur: ~durSet.next(~currentEvent.dur), 
			freq: ~freqSet.next(~currentEvent.freq),
			amp: ~ampSet.next(~currentEvent.amp),
			env: ~envSet[~durSet.next(~currentEvent.dur)],
			cluster: ~clusterSet.next(~currentEvent.cluster),
			int: ~intSet.next(~currentEvent.int)
		)
	})
}).play
)


~rout.stop
