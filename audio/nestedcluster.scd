~data = ();
256.do({|i|
	~data[i.asString.padLeft(3, "0").asSymbol] = Array.rand(6, 0, 9);
})

~clusters = KMeans(16);

~metaclusters = KMeans(4);

~clusters.centroids

~data.do({|values|
	~clusters.add(values)
})

~clusters.update

~clusters.assignments

~data['000']

~clusters.data

~clusters.centroids.do({|cent|
	~metaclusters.add(cent)
})

~metaclusters.assignments

~test = 0 ! 6
~metaclusters.classify(~test)
