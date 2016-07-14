~data = MikroData().loadPathMatch

~keys = ~data.datalib.keys(Array);

~keys = ~keys.collect(_.asString).sort.collect(_.asSymbol);

~names = "/Users/alo/sounds/mikro/train/*".pathMatch.collect({|path|
	path.basename.split($.).first.asSymbol
});

~keys.do({|key, i| ~data.datalib[key].name = ~names[i] });

~lib = ~data.datalib.select({|lib| lib.name == '000_evala' }).first.values.first

~data.fillEventDiff(~keys.first)


~lib.diff.size

~win = Window("..d.i.f.f..", Rect(200, 200, ~lib.diff.size*2+10, 210)).front;
~view = UserView(~win, ~win.view.bounds).background_(Color.black);
~view.drawFunc = {
	~lib.diff.do({|val, i|
//		Pen.color = Color.grey(val.clip(0.0, 1.0));
		Pen.color = Color.white;
		Pen.line(Point(i*2+5, ~win.bounds.height-5), Point(i*2+5, (~win.bounds.height-5)-val.linlin(0, ~lib.diff.maxItem, 0, 200)));
		Pen.stroke
	});
};

~mfccdiff = Array();

~mfccdiff = ~mfccdiff.round((2**7).reciprocal)

~lib.events.doAdjacentPairs({|evA, evB|
	~mfccdiff = ~mfccdiff.add(abs(evB.meanMFCC - evA.meanMFCC).mean)
})


~lib.events.doAdjacentPairs({|evA, evB|
	abs(evB.duration - evA.duration).postln
})

~mfccdiff.maxItem
~mfccdiff.minItem

~win = Window("..d.i.f.f..", Rect(200, 200, ~mfccdiff.size*2+10, 210)).front;
~view = UserView(~win, ~win.view.bounds).background_(Color.black);
~view.drawFunc = {
	~mfccdiff.do({|val, i|
//		Pen.color = Color.grey(val.clip(0.0, 1.0));
		Pen.color = Color.yellow;
		Pen.line(Point(i*2+5, ~win.bounds.height-5), Point(i*2+5, (~win.bounds.height-5)-val.linlin(0, ~mfccdiff.maxItem, 0, 200)));
		Pen.stroke
	});
};
