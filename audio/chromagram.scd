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

SynthDef(\chroma, {|in|
	var fft;
	fft = FFT(LocalBuf(2048), In.ar(in));
	Chromagram.kr(fft).poll(10);
}).add

)

~bus = Bus.audio(s);
