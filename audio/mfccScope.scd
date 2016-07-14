(
SynthDef(\signal, {
	var send, input, amps, frqs, sig, bdws, n = 7, chain, mfcc;
	amps = ArrayControl.kr(\amps, n, 0);
	frqs = ArrayControl.kr(\frqs, n, 1);
	bdws = ArrayControl.kr(\bdws, n, 1);
	send = Impulse.kr(1);
	input = WhiteNoise.ar;
	sig = Mix.fill(n, {|i|
		BPF.ar(input, frqs[i], bdws[i]/frqs[i]) * amps[i]
	});
	chain = FFT(LocalBuf(1024), sig);
	mfcc = MFCC.kr(chain, n);
	SendReply.kr(send, '/mfcc', mfcc);
	Out.ar(0, sig)
}).add;

~frqs = Array.geom(9, 20.0, 2.37)[1..7];
~bdws = [~frqs.first];
~frqs.doAdjacentPairs({|a, b|
	~bdws = ~bdws.add(b - a);
});
)

~synth = Synth(\signal).setn(\frqs, ~frqs).setn(\bdws, ~bdws);
~synth.free
~amps = (0 ! 7);

~mfcc = Array.fill(7, 0.25);
~mfsp = ControlSpec(-1.0, 2.0);

w=Window("---- m.f.c.c. ----", Rect(200, 200, 300, 400)).background_(Color.black).front;
7.do({|i|
	SmoothSlider(w, Rect(i*40+10,10,35,180))
		.action_({|slider|
			~amps[i] = slider.value;
			~synth.setn(\amps, ~amps)
		})
});
UserView(w, Rect(0, 200, 300, 200)).drawFunc_({
	~mfcc.do({|val, i|
		var hgt = ~mfsp.unmap(val) * 180;
		Pen.color = Color.grey(0.3);
		Pen.strokeRect(Rect(i*40+10,10,35,180));
		Pen.color = Color.grey(0.8);
		Pen.fillRect(Rect(i*40+10,180-hgt,35,hgt));
	})
});

r = OSCresponderNode(s.addr, '/mfcc', {|ti, re, ms|
	~mfcc = ms[3..9];
//	~mfcc.postln;
	{w.refresh}.defer;
}).add

r.remove