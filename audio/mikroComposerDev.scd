(

~decoder = Decoder(
	isLocal: false, 
	isUHJ: false
);

~nCoef = 12;
~dur = 5 * 60;

~graphics = MikroGraphics(
	width: 800,
	height: 600,
	sizeX: 30,
	sizeY: 30,
	frameRate: 36,
	remoteAddr: NetAddr("127.0.0.1", 7770),
	vectorSize: ~nCoef,
	trainDur: 5000,
	lRate: 0.1
);

~mikro = Mikro(
	liveInput: false,
	decoder: ~decoder,
	graphics: ~graphics,
	duration: ~dur,
	nCoef: ~nCoef
);

~composer = MikroComposer(~mikro);

~patchRecognizer = PatchRecognizer(~mikro).load("/Users/alo/Data/mikro/110526_160045.plib");

~eq = MasterEQ(4);

)

~patchRecognizer.weightDict


~mikro.initPerformance;

(
~graphics.settings[\groupx] = 5;
~graphics.settings[\groupy] = 5;
~graphics.settings[\transz] = 40;
~graphics.settings[\transx] = -40;
~graphics.settings[\transy] = -12;
~graphics.sendSettings
)

//~graphics.start

~mikro.start(-80.dbamp, 0.05, 30);

// LIVE

(
~ind = Pseq((0..35), inf).asStream;

~ldef = \grains;
~live = ~composer.play(~ldef, Env([0.001, 1.0, 1.0, 0.001], [0.3, 0.4, 0.3], \sine, 2, 1), 
	Pseq(~graphics.states, 1).asStream);

~composer.mapStates(~live, ~composer.descLib[~ldef].metadata.specs.collect({ ~ind.next }) );
)

1019
1023

~composer.unmapStates(~)

// BUF

~events = ~mikro.analyzer.events.select({|ev| 
	(ev.duration > 0.1).and(ev.amps.size > 3).and(ev.duration < 6) 
})
~events.size

~events.do({|ev|
	var max, avg, amps;
	amps = ev.amps.collect(_.at(1));
	[amps.maxItem, amps.sum / ev.amps.size].postln
})

(

Routine({

	~events.do({|ev, i|
		[i, ev.duration].postln;
		~def = \rwarp;
		~id = ~composer.play(~def, ~events.choose.ampsToEnv(8, 'sine', true, true, true), 
			Pseq(~graphics.states, 1).asStream, ev.buffer, ev.duration * 2);
		ev.duration.wait;
	})
}).play
)

~mikro.analyzer.elapsedTime

(

Routine({

	~events.do({|ev, i|
		[i, ev.duration].postln;
		~def = \bufplay;
		~id = ~composer.play(~def, ~events.choose.ampsToEnv(8, 'sine', true, true, true), 
			Pseq(~graphics.states, 1).asStream, ev.buffer, ev.duration * 2);
		ev.duration.wait;
	})
}).play
)

(	
~ev = ~events[2];
~def = \rwarp;
~id = ~composer.play(~def, Env([0.0, 1.0, 1.0, 0.0], [0.1, 0.8, 0.1]), 
	Pseq(~graphics.states, 1).asStream, ~ev.buffer, ~ev.duration * 4);

)

~mikro.analyzer.events.size

(
~rout = Routine({
	
	~ind = Pseq((0..15), inf).asStream;
	
	10.do({
	
		~def = \fbgverb;
		~id = ~composer.play(~def, Env([0.001, 1.0, 1.0, 0.001], [0.3, 0.4, 0.3], \sine, 2, 1), 
			Pseq(~graphics.states, 1).asStream);
		
		~composer.mapStates(~id, ~composer.descLib[~def].metadata.specs.collect({ ~ind.next }) );
		
		
		
	})
}).play
)
~composer.unmapStates(~id)

~composer.releaseSynth(~live, 1)

~composer.releaseSynth(1014, 6);
~composer.releaseSynth(1036, 7);
~composer.releaseSynth(1043, 8);
~composer.releaseSynth(1040, 9)

~graphics.bmu

s.queryAllNodes

~mikro.stop

(
~states = Array.fill(16, 0.0);
w = Window("._._.", Rect(200, 200, 400, 400)).background_(Color.black).front;
w.drawHook = {
	~states.clump(4).do({|row, x|
		row.do({|value, y|
			Pen.color = Color.grey(value);
			Pen.fillRect(Rect(x*100, y*100, 100, 100))
		})
	})
};

~rsp = OSCresponderNode(nil, '/mikro/states', {|ti, re, ms|
	if (ms.isKindOf(ArrayedCollection)) {
		if (ms[1].isKindOf(Int8Array)) {
			~states = ms[1].asFloatArray;
			{w.refresh}.defer;
		}
	}
}).add;
)
~rsp.remove
~states.size

~graphics.start

(
Routine({
	
	100.do({
		~graphics.sendWeights(*Array.rand(12, 0.0, 1.0));
		0.1.wait;
	});
	
	"finished".postln
	
}).play
)

6.fold(0, 5)

~graphics.start

~graphics.states.size

~graphics.settings[\groupx] = 5;
~graphics.settings[\groupy] = 5;
~graphics.settings[\transz] = 40;
~graphics.settings[\transx] = -40;
~graphics.settings[\transy] = -40;

~graphics.sendSettings


~graphics.sendSetting(\symmetry, 1)
~graphics.sendSetting(\add, 0.01)
~graphics.sendPattern(11, 1, 1)
~graphics.sendPattern(0, 0, 1)
~graphics.quit

~flicker = Pxrand(Array.geom(7, 0.001, 2.5), inf).asStream;
~flicker = Pstutter(1, Pseq([0.2, 0.5], inf)).asStream;
~alpha = Pseq([1, 0.5, 0, 1, 1], inf).asStream;
~graphics.putStatesFunction(\flicker, {
	var val = ~flicker.next;
	~graphics.sendPattern(0, 1, val)
//	~graphics.sendPattern(8, 1, val)
});

~graphics.removeStatesFunction(\flicker)

~liveprocs = "/Users/alo/Development/mikro/audio/mikroPROClive.scd".load;
~bufprocs = "/Users/alo/Development/mikro/audio/mikroPROCbuf.scd".load;

e = Array.fill(10, { Array.rand(8*4, 0, 3) });

z = e.collect({|chrm|
	chrm.clump(4).collect({|gn| gn.convertDigits(4).reciprocal })
})

z.do({|levels|
	Env(levels.normalize, levels.lastIndex.reciprocal ! levels.lastIndex, \sine).plot
})

s.sendMsg("/n_free", 1007)