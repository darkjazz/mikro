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

~dur = 600;
~ncoef = 8;
~analyzer = MikroAnalyzer(~dur, ~ncoef, false);
~neuralNet = NeuralNet(~ncoef, ~ncoef * 2, 5, 0.05, 1.0);
)

~neuralNet.weightsh

(
///ANALYZER
~bus = Bus.audio(s);

~trainData = Array();
~currentPatch = (0 ! 5);

~analyzer.putEventResponderFunction(\neuralNet, {|time, re, msg, anl|
		if (msg[2] == 3) {
			if (msg[3..10].mean != 0.25 )
			{
				msg[3..10].postln;
				~neuralNet.train1(msg[3..10], ~currentPatch);
			}
		}
});

)

(

~analyzer.start(~bus, 1, \addToTail, -80.dbamp, 0.05, 20);
SystemClock.sched(0.2, {
	~currentBuf = ~bufs.next;
	if (~currentBuf.isNil) { 
		~bufs = Pseq(~buffers.scramble, 1).asStream;
		~currentBuf = ~bufs.next;	
	};
	~currentPatch = ~currentBuf.path.basename.split($.).first.keep(6).split($_).flat.collect(_.asString.asInteger);
	~currentBuf.postln;
	~currentPatch.postln;
	~analyzer.elapsedTime.postln;
 	Synth.before(~analyzer.synth, \playPatch, [\out, ~bus, \buf, ~currentBuf, \amp, 0]); 
 	if ((~dur - ~currentBuf.duration) > ~analyzer.elapsedTime ) { 
	 	~currentBuf.duration 
	} 
	{ 
		~analyzer.free;
		nil 
	};

})

)



(
~analyzer.putEventResponderFunction(\neuralNet, {|time, re, msg|
	if (msg[2] == 3) {
		if (msg[3..10].mean != 0.25 )
		{			
			~nnOutput = ~neuralNet.calculate(msg[3..10]);
			[~currentPatch, ~nnOutput.round(1)].postln;
		}
	};
});

~analyzer.start(~bus, 1, \addToTail, -80.dbamp, 0.05, 20);

SystemClock.sched(0.2, {
	~currentBuf = ~bufs.next;
	if (~currentBuf.isNil) { 
		~bufs = Pseq(~buffers.scramble, 1).asStream;
		~currentBuf = ~bufs.next;	
	};
	~currentPatch = ~currentBuf.path.basename.split($.).first.keep(6).split($_).flat.collect(_.asString.asInteger);
	~currentBuf.postln;
	~analyzer.elapsedTime.postln;
 	Synth.before(~analyzer.synth, \playPatch, [\out, ~bus, \buf, ~currentBuf, \amp, 0]); 
 	if ((~dur - ~currentBuf.duration) > ~analyzer.elapsedTime ) { 
	 	~currentBuf.duration 
	} 
	{
		~analyzer.free; 
		nil 
	};

});

)

~neuralNet.calculate(Array.rand(9, 0.0, 1.0))

~analyzer.free
