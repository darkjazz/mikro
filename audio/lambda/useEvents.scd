~analyzer = MikroAnalyzer();
~analyzer.loadEvents("/Users/alo/Data/mikro/120626_172959.events")

~intervals = []; 

~analyzer.events.doAdjacentPairs({|evA, evB|
	var diff = ();
	diff['dur'] = evB.start - (evA.start + evA.duration);
	diff['mfcs'] = abs(evA.mfcs.collect(_.at(1)).mean - evB.mfcs.collect(_.at(1)).mean).mean;
	diff['flts'] = abs(evA.flts.collect(_.at(1)) - evB.flts.collect(_.at(1))).mean;
	diff['amps'] = abs(evA.amps.collect(_.at(1)) - evB.amps.collect(_.at(1))).mean;
	diff['frqs'] = abs(evA.frqs.collect(_.at(1)) - evB.frqs.collect(_.at(1))).mean / 10000.0;
	diff['total'] = diff.values.sum;
	~intervals = ~intervals.add(diff)
})

~clusters = Array.with(0) ++ (~intervals.selectIndices({|value| value.total > 0.4 }) + 1)

~clumps = Array();
~clusters.doAdjacentPairs({|a, b|
	~clumps = ~clumps.add(b - a)
})

~eventClusters = ~analyzer.events.clumps(~clumps).do({|cluster|
	[cluster.collect(_.duration).round(0.01), cluster.collect(_.meanAmp).collect(_.ampdb).round(0.01)].postln
})


abs(~analyzer.events[0].meanAmp - ~analyzer.events[1].meanAmp)

~clusters

~analyzer.events[0].mfcs

~analyzer.events[5].start

~analyzer.events.do({|ev, i|
	[i, ev.flts.collect(_.at(1)).sum].postln
})

~analyzer.events[85].flts.do({|arr|
	if(arr[1].isNaN) {
		arr[1] = 0.0
	}
})

~metadata = UGenExpressionTree.loadMetadataFromDir.select({|data|
	data.stats.mfcc.size == 20 && data.stats.mfcc.collect(_.mean).sum.isNaN.not
});

~metadata.size

~nclusters = 64;
~kmeans = KMeans(~nclusters);

~metadata.do({|data|
	~kmeans.add(data.stats.mfcc.collect(_.mean))
})

~kmeans.update

~eventClass = Array();


~analyzer.events.do({|ev, i|
	~eventClass = ~eventClass.add(~kmeans.classify(ev.meanMFCC))
})

~eventClass

~eventSynthDefs = Array();

~analyzer.events.do({|ev, i|
	var diff = 100, best;
	~kmeans.assignments.selectIndices({|ind| ind == ~eventClass[i] }).do({|dataindex|
		if (abs(ev.meanMFCC - ~kmeans.data[dataindex]).sum < diff) {
			diff = abs(ev.meanMFCC - ~kmeans.data[dataindex]).sum;
			best = dataindex
		}
	});
	~eventSynthDef = ~eventSynthDef.add( ~metadata[best].defname )
	
})


~eventSynthDef.do(_.postln)

s.loadDirectory("/Users/alo/Data/gep/synthdefs")

Routine({
	
})

~boundaries = [0] ++  ~analyzer.clusterEvents(0.33)
~bou.doAdjacentPairs({|a, b| b-a })

(Array.with(0) ++ (~analyzer.generateClusterBoundaries(0.33) + 1)).do({|a, b|
	
})



~analyzer.events[0].meanMFCC

~clustered = ~analyzer.clusterEvents(~analyzer.eventdiff.mean + (~analyzer.eventdiff.stdDev / 2))



~clustered.do({|cluster|
	cluster.size.postln
})

