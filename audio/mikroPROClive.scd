(
	fbgverb: (
		def: SynthDef(\fbgverb, {|out, in, gate = 1.0, wrp, dur, frq, wsz, dns, rnd, amp, 
				xang, yang, zang|
			var bufs, recs, ptrs, phases, deltimes, output, trigs, input, w, x, y, z;
			deltimes = [0, dur * 0.5, dur];
			bufs = Array.fill(3, { LocalBuf(SampleRate.ir) });
			ptrs = Array.fill(3, {|i| LFSaw.kr(wrp, 1).range(0, 1) });
			trigs = Array.fill(3, {|i| TDelay.kr(Impulse.kr(wrp*2/3), deltimes@i) });
			input = In.ar(in);
			recs = Mix.fill(3, {|i|
				RecordBuf.ar(input, bufs@i, loop:0.0, trigger: trigs@i);
			});
			output = Mix.fill(3, {|i|
				Warp1.ar(1, bufs@i, ptrs@i, frq, wsz, -1, dns, rnd)
					* EnvGen.kr(
						Env([0.0,1.0,1.0,0.0],[0.3,0.4,0.3],\sine, 0, 3),
						trigs@i, timeScale: dur
					)
			}) * EnvGen.kr(Env([0.001, 1.0, 1.0, 0.001], [0.3, 0.4, 0.3], \sine, 2, 1), 
				gate, doneAction: 2);
			#w, x, y, z = A2B.ar(
					output,
					DelayN.ar(output, 0.01, 0.01),
					DelayN.ar(output, 0.02, 0.02),
					DelayN.ar(output, 0.03, 0.03)
			) * amp;
			Out.ar(out, AtkRotateXYZ.ar(w, x, y, z, xang, yang, zang))
		}),
		specs: (
			wrp: ControlSpec(0.005, 0.5),
			dur: ControlSpec(6, 12),
			frq: ControlSpec(0.25, 2.0, step: 1/4),
			wsz: ControlSpec(0.01, 0.2),
			dns: ControlSpec(1, 10),
			rnd: ControlSpec(0, 0.01),
			amp: ControlSpec(0.3, 1.0),
			xang: ControlSpec(-pi, pi),
			yang: ControlSpec(-pi, pi),
			zang: ControlSpec(-pi, pi)
		)
	),
	
	latch: (
		def: SynthDef(\latch, {|out, in, th, eb1, eb2, rt, damp=0.5, bw=0.5, sp, dry, early, tail, 				gate=1, amp, xang, yang, zang|
			
			var input, freq, trig, fft, gtrig, rL, rR, w, x, y, z, env, sig, pitch, a, b, c, d;
			env = Control.names([\env]).kr(Env.newClear(8).asArray);
			input = In.ar(in);
			pitch = Pitch.kr(input)[0];
			fft = FFT(LocalBuf(512), input);
			trig = Onsets.kr(fft, th);
			freq = Latch.ar(pitch, trig);
			gtrig = Dust.kr(SinOsc.kr(LFNoise2.kr(0.5)).range(8, 64));
			sig = SinGrain.ar(
				gtrig, 
				Lag.kr(Amplitude.kr(input), 0.1).linlin(0.0, 1.0, 0.001, 0.01), 
				Select.kr(TIRand.kr(0, 6, gtrig), 
					freq * Array.geom(7, 0.125, 2**(1/7) ) * (1..7)), 
				EnvGen.kr(Env([0.001, 1.0], [1], \sine), trig, timeScale: TRand.kr(0.3, 3.0, trig))
			);
			#rL, rR = GVerb.ar(sig + Dust2.ar(pitch), 500, rt, damp, bw, sp, dry, early, tail, 500)
				* EnvGen.kr(env, gate, doneAction: 2);
			a = BLowShelf.ar(rL, 100, 0.5, 0.5);
			b = BPeakEQ.ar(rR, 800, 5.0, -16);
			c = BHiShelf.ar(rL, 10000, 1.0, 1.0);
			d = BPeakEQ.ar(rR, 3000, 3.0, -8);
			#w, x, y, z = A2B.ar(a, b, c, d);
			Out.ar(out, AtkRotateXYZ.ar(w, x, y, z, xang, yang, zang))
		}).add,
		specs: (
			th: ControlSpec(-40.dbamp, -20.dbamp),
			rt: ControlSpec(0.5, 5),
			sp: ControlSpec(5, 20),
			dry: ControlSpec(0.0, 0.01),
			early: ControlSpec(0.01, 0.0),
			tail: ControlSpec(0.3, 0.6),
			amp: ControlSpec(0.3, 0.6),
			xang: ControlSpec(-pi, pi),
			yang: ControlSpec(-pi, pi),
			zang: ControlSpec(-pi, pi)
		)
	),
	
	cliq: (
		def: SynthDef(\cliq, {|out, in, th, gate=1, amp, sdur, pth, cdur=0.001, quant=0.107|
	
			var  w, x, y, z, input, freq, trig, fft, gtrig, bfr, env, sig, pch, snd, senv, a, b, c, d;
			var ampctr;
			env = EnvControl.kr;
			input = In.ar(in);
			ampctr = Lag2.kr(Amplitude.kr(input), 0.1);
			pch = Pitch.kr(input)[0];
			fft = FFT(LocalBuf(512), input);
			trig = Trig.ar(Onsets.kr(fft, th), quant);
			gtrig = Trig.ar(trig, quant*8);
			senv = EnvGen.kr(Env([0.001, 1.0, 1.0, 0.001], [0.01, sdur, 0.1], \exp), gtrig);
			sig = Mix(
				BPF.ar(
					LFSaw.ar(pch, 0, Decay.ar(trig, cdur * LFNoise1.ar(4).abs)),
					TRand.kr(pi**5, (pi**5)*(2**(89/17)), trig).round(2**(1/17)),Ê
					0.2,Ê
					25 * LFNoise1.ar(8).range(0, 1)Ê
				).fold(-1, 1)) * ampctr.linlin(0, 1, 0.1, 0.6);
			sig = Mix(sig + GVerb.ar(sig, 100, 20, 0.9, 0.9, 5, 0, 0, 0.05));
			snd = Reverb.ar(Select.ar(pch > pth, 
				[Mix(SinOsc.ar(Array.geom(7, Rand(40.0, 50.0), 2**(1/5)), 0, 
					Array.geom(7, 1.0, 15/16), 0.5pi).tanh) * 0.3, 
					SinOsc.ar(pch * 100, 0.5pi, Amplitude.kr(input))
			]), 1).fold(-1, 1) * senv;
			sig = Mix(sig + snd) * EnvGen.kr(env, gate, doneAction: 2);
			#a, b, c, d = [
				BLowShelf.ar(sig, 100, 0.5, 0.5),
			 	BPeakEQ.ar(sig, 800, 5.0, -8),
				BHiShelf.ar(sig, 10000, 1.0, 1.0),
				BPeakEQ.ar(sig, 3000, 3.0, -4)
			];
			#w, x, y, z = A2B.ar(a, b, c, d);
		 	Out.ar(out, AtkRotateXYZ.ar(w, x, y, z, 
				TRand.kr(-pi, pi, trig), TRand.kr(-pi, pi, trig), TRand.kr(-pi, pi, trig) ))
		}),
		
		specs: (
			th: ControlSpec(-30.dbamp, -10.dbamp),
			amp: ControlSpec(0.2, 0.8),
			sdur: ControlSpec(0.01, 0.3),
			cdur: ControlSpec(0.001, 0.007),
			pth: ControlSpec(400.0, 1000.0)
		)
	),
	
	grains: (
		def: SynthDef(\grains, {|out, in, gate=1, maxdel=0.1, xang, yang, zang, bfrq|
			var a, b, c, d, env, trig, dns, frq, dur, amz, w, x, y, z, input, rnd, ebf;
			env = EnvControl.kr;
			dns = ArrayControl.kr(\dns, 4, 1);
			dur = ArrayControl.kr(\dur, 4, 1);
			rnd = ArrayControl.kr(\rnd, 4, 1);
			frq = ArrayControl.kr(\frq, 4, 1);
			amz = ArrayControl.kr(\amz, 4, 1);
			input = CombL.ar(In.ar(in), frq, frq, 4) * EnvGen.kr(env, gate, doneAction: 2);
			trig = DelayL.kr(Impulse.kr(dns), maxdel, TRand.kr(0, rnd, Impulse.kr(dns*2)));
			#a, b, c, d = InGrain.ar(trig, dur, 
				(PitchShift.ar(input, pitchRatio: frq
					add: LPF.ar(LFSaw.ar(bfrq*frq), LFSaw.ar((1..4)).exprange(40, 4000)) 
				)*10).tanh, 
				amz);
			#w, x, y, z = A2B.ar(a, b, c, d);
			Out.ar(out, AtkRotateXYZ.ar(w, x, y, z, xang, yang, zang))
		}),
		
		specs: (
			bfrq: ControlSpec(0.125, 1, step: 0.125),
			xang: ControlSpec(-pi, pi),
			yang: ControlSpec(-pi, pi),
			zang: ControlSpec(-pi, pi)
		),
		
		array: (
			dns: Array.geom(4, 10, 1.618),
			dur: Array.geom(4, 0.005, 1.618),
			rnd: Array.geom(4, 0.01, 1.03),
			frq: Array.series(4, 0.107, 0.107),
			amz: Array.geom(4, 0.4, 1.3)
		)
	),
	
	streamverb: (
		def: SynthDef(\streamverb, {|out, in, rmsize=300, rtime, hfd, inbw, spread, dry, early, tail, 				max=300, amp, gate=1.0, slope=0.8, xang, yang, zang|
			var sig, gverb, ps, ampctr, pu, output, env, a, b, c, d, w, x, y, z;
			sig = In.ar(in);
			ampctr = Lag.kr(Amplitude.kr(sig), 0.25);
			env = EnvGen.kr(EnvControl.kr, gate, doneAction: 2);
			gverb = GVerb.ar(sig, rmsize, rtime, hfd, inbw, spread, dry, early, tail, max) * env;
			ps = PitchShift.ar(gverb, LFNoise2.kr(0.27, 0.19, 0.2), 1.66, ampctr * amp, ampctr * amp);
			pu = DelayC.ar(
				PitchShift.ar(gverb, LFNoise2.kr(0.31, 0.19, 0.2), 0.33, ampctr * amp, ampctr * amp),
				0.05, 0.05);
			sig = Compander.ar(ps ++ pu, ps ++ pu, 0.95, slope, 0.1, 0.04, 0.1);
			#a, b, c, d = LeakDC.ar(sig);
			#w, x, y, z = A2B.ar(a, b, c, d);
			Out.ar(out, AtkRotateXYZ.ar(w, x, y, z, xang, yang, zang))
		}),
		
		specs: (
			rtime: ControlSpec(5, 30),
			hfd: ControlSpec(0.2, 0.8),
			inbw: ControlSpec(0.8, 0.2),
			spread: ControlSpec(4, 16),
			dry: ControlSpec(0.3, 0.05),
			early: ControlSpec(0.5, 0.1),
			tail: ControlSpec(0.4, 0.8),
			amp: ControlSpec(0.5, 1.0),
			xang: ControlSpec(-pi, pi),
			yang: ControlSpec(-pi, pi),
			zang: ControlSpec(-pi, pi)			
		)
	)	
);