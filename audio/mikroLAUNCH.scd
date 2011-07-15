(
~decoder = Decoder(
	isLocal: true, 
	isUHJ: true
);

~nCoef = 8;
~dur = 1 * 60;

~graphics = MikroGraphics(
	width: 800,
	height: 600,
	sizeX: 40,
	sizeY: 40,
	frameRate: 30,
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

~eq = MasterEQ(4);

~onsetActions = [
	(
		actionName: "none",
		action: {
			"none".postln;
			~mikro.analyzer.onsetAction = nil;
			~mikro.analyzer.runningOnsetAction = nil;
		}
	),
	(
		actionName: "bufs",
		action: {
			"bufs".postln;
			~mikro.analyzer.runningOnsetAction = {|ti, re, ms|
				var coll, event;
				if (0.25.coin) {
					coll = ~mikro.analyzer.events.select({|ev| ev.duration > 1 });
					event = coll.wchoose((coll.size..1).normalizeSum);
					~mikro.graphics.states.postln;
					~composer.startBufSynth(
						\bufplay, 
						Env([0, 1, 1, 0], [0.1, 0.8, 0.1], \sine, 2, 1),
						event.buffer,
						event.buffer,
						event.duration,
						1,
						Pseq(~mikro.graphics.states, inf).asStream
					)
				}
			}
		}
	),
	(
		actionName: "bufseq",
		action: {
			"bufseq".postln;
			~mikro.analyzer.onsetAction = {|time, re, ms|
				Routine({
					var coll, events;
					coll = ~mikro.analyzer.events.select({|ev| ev.duration > 1 });
					if (coll.size > 4) {
						events = coll.drop(coll.size - 4);
						events.do({|ev|
							~composer.startBufSynth(
								\bufplay,
								Env([0, 1, 1, 0], [0.1, 0.8, 0.1], \sine, 2, 1),
								ev.buffer,
								ev.buffer,
								ev.duration,
								1,
								Pseq(~mikro.graphics.states, inf).asStream
							);
							(ev.duration * 0.25).wait;
						})
					}
				}).play
			}
		}
	),
	(
		actionName: "synthseq",
		action: {
			"synthseq".postln;
			~mikro.analyzer.runningOnsetAction = {|ti, re, ms|
				~composer.startSynthSynth(
					~composer.synthProcs.keys(Array).choose,
					Env.perc(rrand(0.01, 0.1), 1.0, rrand(0.05, 0.2), rrand(8, -8) ),
					ms[3].explin(0.001, 1.0, 0.05, 0.4),
					~mikro.analyzer.currentPitch ? Array.geom(24, pi*20, 2**(1/24)).choose,
					Pseq(~mikro.graphics.bmu.vector.clip(0.0, 1.0), inf).asStream
				)
			}
		}
	),
	(
		actionName: "allseq",
		action: {
			"allseq".postln;
			~mikro.analyzer.onsetAction = {|time, re|
				if (~mikro.analyzer.events.size > 10)
				{
				~composer.startSequence([2, 4].choose, ~mikro.analyzer.events, 
					~composer.bufProcs.keys(Array).choose, ~composer.intervals.dict.keys.choose
				)
				}
			}
		}
	)
];

~mikro.makeGui(~composer, ~onsetActions);


)



~mikro.graphics.quit

~mikro.analyzer.events.size
