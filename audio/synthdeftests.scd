SynthDef(\fbgverb, {|out, in, gate = 1.0, i_wrp, frq, wsz, dns, rnd, amp, 
				xang, yang, zang|
	var bufs, recs, ptrs, phases, deltimes, output, trigs, input, w, x, y, z;
	deltimes = [0, 1 / i_wrp * 0.5, 1 / i_wrp];
	bufs = Array.fill(3, { LocalBuf(SampleRate.ir * 2) });
	ptrs = Array.fill(3, {|i| LFSaw.kr(i_wrp, 0, 0.5, 0.5) });
	trigs = Array.fill(3, {|i| DelayN.kr(Impulse.kr(i_wrp * (2 / 3)), 
		deltimes@i, deltimes@i) });
	input = In.ar(in);
	recs = Mix.fill(3, {|i|
		RecordBuf.ar(input, bufs@i, loop:0.0, trigger: trigs@i);
	});
	output = Mix.fill(3, {|i|
		Warp1.ar(1, bufs@i, ptrs@i, frq, wsz, -1, dns, rnd)
			* EnvGen.kr(
				Env([0.0,1.0,1.0,0.0],[0.3,0.4,0.3],\sine, 0, 3),
				trigs.rotate(-1)@i, timeScale: 1.0 / i_wrp
			)
	}) * EnvGen.kr(Env([0.001, 1.0, 1.0, 0.001], [0.3, 0.4, 0.3], \sine, 2, 1), 
		gate, doneAction: 2);
			
}).add;
