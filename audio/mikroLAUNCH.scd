(
~decoder = Decoder(
	isLocal: true, 
	isUHJ: true
);

~mikro = Mikro(
	liveInput: false,
	decoder: ~decoder,
	duration: 120,
	nCoef: 8
);

~composer = MikroComposer(~mikro);

~mikro.analyzer.onsetAction = {|time, re|
	if (~composer.activeLiveSynths.size == 0) {
		~composer.startLiveSynth(\fbgverb, Env([0, 1, 1, 0], [0.1, 0.4, 0.5], \sine, 2, 1))
	};
};

~mikro.makeGui;

)

~mikro.analyzer.onsetAction = nil

~composer.freeSynth(1125, 10)

~composer.activeLiveSynths['1004'].set("i_wrp", 0.1)

~mikro.visual.putStatesFunction(\states, {|states|
	states.postln
})
~mikro.visual.removeStatesFunction(\states)

~mikro.makeGui

~mikro.analyzer.events.size

~mikro.initPerformance();

~mikro.start(onsetGate: -80.dbamp, lag: 0.05, msgRate: 20);


~mikro.visual.sendPattern(6, 1, 1)

~mikro.visual.sendPattern(0, 0, 1)

~mikro.visual.sendMsg("settings", 0.01)

~mikro.visual.start

(
r = Routine({
	
	inf.do({
		var arr = Array.rand(8, 0.0, 1.0);
		~mikro.visual.sendWeights(*arr);
		0.1.wait;
	});
	
}).play
)


~mikro.visual.sendPattern(6, 1, 0.5)

~mikro.visual.fadeInPattern(5, 1, 10)

~mikro.visual.fadeOutPattern(7, 10)

~mikro.visual.sendSetting(\add, 0.005)

~mikro.visual.sendSetting(\transx, -8.0)

~mikro.visual.start(1)

(
~mikro.visual.quit;
r.stop
)
~mikro.visual.collectSettings
~mikro.stop
~mikro.analyzer.free

~mikro.freeInput

~mikro.decoder.free