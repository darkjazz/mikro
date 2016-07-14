Array.with(

	SynthDef(\fbgverb, {|out, in, gate = 1.0, i_wrp, frq, wsz, dns, rnd, amp, 
				xang, yang, zang|
			var bufs, recs, ptrs, phases, deltimes, output, trigs, input, bf;
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
			bf = FoaEncode.ar([
					output,
					DelayN.ar(output, 0.01, 0.01),
					DelayN.ar(output, 0.02, 0.02),
					DelayN.ar(output, 0.03, 0.03)],
				FoaEncoderMatrix.newAtoB
			) * amp;
			Out.ar(out, FoaTransform.ar(bf, 'rtt', xang, yang, zang))
		}, metadata: 
		(
			type: \live, activeIndex: 0, maxweight: 0.8, mindur: 30.0, fadetime: 10.0,
			specs: (
				i_wrp: ControlSpec(0.0625, 0.5, step: 0.0625),
				frq: ControlSpec(0.25, 2.0, step: 1/4),
				wsz: ControlSpec(0.01, 0.2),
				dns: ControlSpec(1, 10),
				rnd: ControlSpec(0, 0.01),
				amp: ControlSpec(0.3, 1.0),
				xang: ControlSpec(-pi, pi),
				yang: ControlSpec(-pi, pi),
				zang: ControlSpec(-pi, pi)
			)
		)
	),
	
	SynthDef(\latch, {|out, in, th, eb1, eb2, rt, damp=0.5, bw=0.5, sp, dry, early, tail, gate=1, quant, index, amp, xang, yang, zang|
			
		var input, freq, trig, fft, gtrig, rL, rR, bf, env, sig, pitch, a, b, c, d;
		env = Control.names([\env]).kr(Env.newClear(8).asArray);
		input = In.ar(in);
		pitch = Tartini.kr(input).first;
		fft = FFT(LocalBuf(512), input);
		trig = Trig.kr(Onsets.kr(fft, th), quant);
		freq = Latch.ar(pitch, trig);
		gtrig = Dust.kr(SinOsc.kr(LFNoise2.kr(0.5)).range(8, 64));
		sig = FMGrain.ar(
			gtrig, 
			Lag.kr(Amplitude.kr(input), 0.1).explin(0.0001, 1.0, 0.006, 0.08), 
			Select.kr(TIRand.kr(0, 6, gtrig), 
				freq * Array.geom(7, 0.125, 2**(1/21) )), 
			freq.linlin(20.0, 20000.0, 40.0, 640.0),
			TRand.kr(index*0.5, index*2.0, gtrig),
			EnvGen.kr(Env([1, 1, 0], [0.5, 0.5], \sine), trig, timeScale: TRand.kr(0.3, 3.0, trig))
		).distort * Decay2.ar(input, 0.01, 0.5, LFPulse.ar(pitch).range(0.25, 1.0));
		#rL, rR = GVerb.ar(sig, 50, rt, damp, bw, sp, dry, early, tail, 50) ** 2.0
			* EnvGen.kr(env, gate, doneAction: 2);
		a = DelayN.ar(BLowShelf.ar(rL, 100, 0.5, 0.5), 0.5, LFNoise2.kr(1/11).range(0.1, 0.5));
		b = DelayN.ar(BPeakEQ.ar(rR, 800, 5.0, -16), 0.5, LFNoise2.kr(1/13).range(0.1, 0.5));
		c = DelayN.ar(BHiShelf.ar(rL, 10000, 1.0, 1.0), 0.5, LFNoise2.kr(1/7).range(0.1, 0.5));
		d = DelayN.ar(BPeakEQ.ar(rR, 3000, 3.0, -8), 0.5, LFNoise2.kr(1/17).range(0.1, 0.5));
		bf = FoaEncode.ar([a, b, c, d], FoaEncoderMatrix.newAtoB);
		Out.ar(out, FoaTransform.ar(bf, 'rtt', xang, yang, zang) * amp)
	}, metadata:
		(		
			type: \live, activeIndex: 4, maxweight: 0.2, mindur: 10.0, fadetime: 3.0,
			specs: (
				th: ControlSpec(-40.dbamp, -12.dbamp),
				rt: ControlSpec(5, 25),
				sp: ControlSpec(5, 20),
				dry: ControlSpec(1.0, 0.5),
				early: ControlSpec(0.01, 0.1),
				tail: ControlSpec(0.04, 0.01),
				amp: ControlSpec(0.05, 0.2),
				quant: ControlSpec(0.0625, 0.25, step: 0.0625),
				index: ControlSpec(5, 20),
				xang: ControlSpec(-pi, pi),
				yang: ControlSpec(-pi, pi),
				zang: ControlSpec(-pi, pi)
			)		
		)
	),
	
	SynthDef(\cliq, {|out, in, th, gate=1, amp, sdur, pth, cdur=0.001, quant=0.107|
	
		var  bf, input, freq, trig, fft, gtrig, bfr, env, sig, pch, snd, senv, a, b, c, d;
		var ampctr;
		env = EnvControl.kr;
		input = In.ar(in);
		ampctr = Lag2.kr(Amplitude.kr(input), 0.1);
		pch = Tartini.kr(input).first;
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
		]), 1).fold(-0.9, 0.9) * senv;
		sig = Mix(sig + snd + trig.wrap(-0.5, 0.5) ).tanh * EnvGen.kr(env, gate, doneAction: 2);
		#a, b, c, d = [
			BLowShelf.ar(sig, 100, 0.5, 0.5),
		 	BPeakEQ.ar(sig, 800, 5.0, -8),
			BHiShelf.ar(sig, 10000, 1.0, 1.0),
			BPeakEQ.ar(sig, 3000, 3.0, -4)
		];
		bf = FoaEncode.ar([a, b, c, d], FoaEncoderMatrix.newAtoB) * amp;
	 	Out.ar(out, FoaTransform.ar(bf, 'rtt',
	 		TRand.kr(-pi, pi, trig), TRand.kr(-pi, pi, trig), TRand.kr(-pi, pi, trig) ))
	}, metadata:
		(
			type: \live, activeIndex: 3, maxweight: 0.2, mindur: 10.0, fadetime: 2.0,
			specs: (
				th: ControlSpec(-30.dbamp, -12.dbamp),
				amp: ControlSpec(0.1, 0.4),
				sdur: ControlSpec(0.01, 0.3),
				cdur: ControlSpec(0.001, 0.007),
				pth: ControlSpec(400.0, 1000.0),
				quant: ControlSpec(1/18, 1/2.25, step: 1/18),
				cdur: ControlSpec(0.05, 0.001)
			)		
		)
	),
	
	SynthDef(\grains, {|out, in, gate=1, maxdel=0.1, amp, xang, yang, zang, bfrq|
		var a, b, c, d, env, trig, dns, frq, dur, amz, bf, input, rnd, ebf;
		env = EnvControl.kr;
		dns = Array.geom(4, 10, 1.618);
		dur = Array.geom(4, 0.005, 1.618);
		rnd = Array.geom(4, 0.01, 1.03);
		frq = Array.series(4, 0.107, 0.107);
		amz = Array.geom(4, 0.4, 1.3);
		input = CombL.ar(In.ar(in), frq, frq, 4) * EnvGen.kr(env, gate, doneAction: 2);
		trig = DelayL.kr(Impulse.kr(dns), maxdel, TRand.kr(0, rnd, Impulse.kr(dns*2)));
		#a, b, c, d = InGrain.ar(trig, dur, 
			(PitchShift.ar(input, pitchRatio: frq
				add: LPF.ar(LFSaw.ar(bfrq*frq), LFSaw.ar((1..4)).exprange(40, 4000)) 
			)*10).tanh, 
			amz);
		bf = FoaEncode.ar([a, b, c, d], FoaEncoderMatrix.newAtoB);
		Out.ar(out, FoaTransform.ar(bf, 'rtt', xang, yang, zang) * amp)
	}, metadata:
		(
			type: \live, activeIndex: 1, maxweight: 0.3, mindur: 15.0, fadetime: 6.0,
			specs: (
				bfrq: ControlSpec(0.125, 1, step: 0.125),
				amp: ControlSpec(1.0, 0.6),
				xang: ControlSpec(-pi, pi),
				yang: ControlSpec(-pi, pi),
				zang: ControlSpec(-pi, pi)
			)		
		)
	),
	
	SynthDef(\streamverb, {|out, in, rmsize=300, rtime, hfd, inbw, spread, dry, early, tail, max=300, amp, gate=1.0, slope=0.8, xang, yang, zang|
		var sig, gverb, ps, ampctr, pu, output, env, a, b, c, d, bf;
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
		bf = FoaEncode.ar([a, b, c, d], FoaEncoderMatrix.newAtoB);
		Out.ar(out, FoaTransform.ar(bf, 'rtt', xang, yang, zang) * amp)
	}, metadata: 
		(
			type: \live, maxweight: 0.4, mindur: 30.0, fadetime: 15.0,
			activationRange: (min: 0, max: 1),
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
	),
	
	SynthDef(\arhythmic, {|out, in, gate = 1, drB=0.125, amp=0.5, th=0.01, quant=0.25|
		var sig, trigs, fft, beat, env, input, sB, pch, ampctr, bfft;
		var af, bf, trigB;
		input = In.ar(in);
		env = EnvControl.kr;
		pch = Tartini.kr(input).first;
		fft = FFT(LocalBuf(1024), input);
		ampctr = Lag.kr(Amplitude.kr(input), 0.25);
		trigB = Trig.kr(Onsets.kr(fft, th), quant);
		sB = Gendy3.ar(2, 5, 0.5, 0.5, pch, 0.25, 0.25, 21, 21)
			* EnvGen.kr(Env([1, 1, 0], [0.25, 0.75], \sine), trigB, timeScale: drB);
		sB = GVerb.ar(sB.tanh, LFSaw.kr(LFSaw.kr(1).range(0.5, 2)).range(4, 20), 
			Latch.kr(ampctr, trigB)).first;
		sB = DelayN.ar(CombC.ar(sB, 0.25, 0.25, 1), 0.5, LFSaw.kr(1.5).range(0.0625, 0.5).round(0.0625));
		bfft = FFT(LocalBuf(1024), Normalizer.ar(sB, -6.dbamp) * amp);
		af = Array.fill(4, { IFFT(PV_Diffuser(bfft, trigB)) });
		bf = FoaEncode.ar(af, FoaEncoderMatrix.newAtoB);
		Out.ar(out, FoaTransform.ar(bf, 'rtt', 
			TRand.kr(pi, -pi, trigB), 
			TRand.kr(pi, -pi, trigB), 
			TRand.kr(pi, -pi, trigB)) * EnvGen.kr(env, gate, doneAction: 2)
		);
	}, metadata: (
			type: \live, activeIndex: 2, maxweight: 0.2, mindur: 10.0, fadetime: 3.0,
			specs: (
				drB: ControlSpec(0.0625, 0.25, step: 0.0625),
				th: ControlSpec(-20.dbamp, -6.dbamp, default: -12.dbamp),
				quant: ControlSpec(0.0625, 1.0, step: 0.0625, default: 0.25),
				amp: ControlSpec(0.4, 0.8)
			)		
		)
	),
			
	SynthDef(\bufplay, {|out, buf, amp, rmp, rtm, hfr, pls, rate=1.0, dur, xang, yang, zang, gate=1|
		var sig, a, b, c, d, del, amps, bf, env, rev, flt;
		del = Array.geom(4, 0.008, 1.618);
		amps = Array.geom(4, 1.0, 0.918);
		sig = PlayBuf.ar(1, buf, rate, loop: 0, doneAction: 2);
		rev = Reverb.ar(sig * rmp, rtm);
		flt = HPF.ar(rev, hfr, LFPulse.kr(pls).range(0.2, 1));
		sig = sig + flt;
		a = sig;
		b = DelayN.ar(sig, 0.1, del[1], amps[1]);
		c = DelayN.ar(sig, 0.1, del[2], amps[2]);
		d = DelayN.ar(sig, 0.1, del[3], amps[3]);
		bf = FoaEncode.ar([a, b, c, d], FoaEncoderMatrix.newAtoB);
		Out.ar(out, FoaTransform.ar(bf, 'rtt', xang, yang, zang) * amp)
	}, metadata: 
		(
			type: \proc,
			specs: (
				amp: ControlSpec(0.5, 2.0),
				rmp: ControlSpec(0.2, 0.07),
				rtm: ControlSpec(4, 10),
				hfr: ControlSpec(6000.0, 12000.0, step: 2**(1/24)),
				pls: ControlSpec(12, 24, step: 1),
				xang: ControlSpec(-pi, pi),
				yang: ControlSpec(-pi, pi),
				zang: ControlSpec(-pi, pi)
			)		
		)
	),
	
	SynthDef(\bufmod, {|out, buf, freqc, bufm, freqm, wsz, pch, dur, amp, wrate, pd, td, maxdel=0.5, xang, yang, zang, gate=1|
		var sig, bf, winsize, env, a, b, c, d, del, shift;
		del = Array.geom(4, 0.01, 1.618);
		shift = Array.geom(4, 35/36, 36/35);	
		env = EnvControl.kr(\env, 16);
		sig = PitchShift.ar(Osc.ar(buf, freqc, Osc.ar(bufm, freqm)), 
			wsz, pch, pd, td) * EnvGen.kr(env, gate, timeScale: dur, doneAction: 2);
		#a, b, c, d = Array.fill(4, {|i|
			PitchShift.ar(DelayN.ar(sig ** 0.5, maxdel, del[i]), 0.1, shift[i]);
		});	
		bf = FoaEncode.ar([a, b, c, d], FoaEncoderMatrix.newAtoB);
		Out.ar(out, FoaTransform.ar(bf, 'rtt', xang, yang, zang) * amp)
	}, metadata: 
		(
			type: \proc,
			specs: (
				freqc: ControlSpec(0.125, 2, step: 0.125), 
				freqm: ControlSpec(2, 0.125, step: 0.125),
				wsz: ControlSpec(0.01, 0.2),
				pch: ControlSpec(0.125, 2.0, step: 0.125),
				amp: ControlSpec(0.5, 2.0),
				wrate: ControlSpec(2, 16, step: 1),
				pd: ControlSpec(0.0, 0.6),
				td: ControlSpec(0.0, 0.6),
				xang: ControlSpec(-pi, pi),
				yang: ControlSpec(-pi, pi),
				zang: ControlSpec(-pi, pi)			
			)		
		)
	),
	
	SynthDef(\tyhi, {|out, in, gate = 1.0, amp = 1.0, warp = 0.01, stf, enf, buf, rand, grenv = -1, dur=4, tdur, maxdel=0.2, xang, yang, zang|
		
		var sig, bf, point, trig, input, freqs, actr, a, b, c, d, del, shift;
		del = Array.geom(4, 0.01, 1.618);
		shift = Array.geom(4, 35/36, 36/35);	
		input = In.ar(in);
		actr = Slope.kr(Amplitude.kr(input)) > 0.2;
		trig = Trig.kr(actr, tdur);
		sig = Warp1.ar(1, 
			buf, 
			LFSaw.kr(warp, 1, 0.5, 0.5),
			EnvGen.kr(Env([stf, enf], [tdur], \exp), trig),
			TRand.kr(0.01, 0.1, trig), 
			grenv, 
			Select.kr(CoinGate.kr(0.5, trig), [
				SinOsc.kr(Rand(4, 32), 0, 5, 10), 
				LFPar.kr(Rand(4, 32), rrand(0, pi), LFSaw.kr(5, 0, 1.5, 2), 5)
			]), 
			rand) ** 0.5 * EnvGen.kr(EnvControl.kr(\env, 16), gate, timeScale: dur, doneAction: 2);
		sig = sig + (Reverb.ar(sig, 20) * LFNoise0.kr(LFNoise0.kr(0.3, 1.0, 2.0), 
			0.3, 0.3).floor);
		#a, b, c, d = Array.fill(4, {|i|
			PitchShift.ar(DelayN.ar(sig, maxdel, del[i]), 0.1, shift[i]);
		});	
		bf = FoaEncode.ar([a, b, c, d], FoaEncoderMatrix.newAtoB);
		Out.ar(out, FoaTransform.ar(bf, 'rtt', xang, yang, zang) * amp)
	}, metadata:
		(
			type: \proc,
			specs: (
				amp: ControlSpec(0.5, 3.0),
				warp: ControlSpec(0.01, 0.1),
				stf: ControlSpec(0.5, 2.0, step: 0.25),
				enf: ControlSpec(0.5, 2.0, step: 0.125),
				rand: ControlSpec(0.0, 0.01),
				tdur: ControlSpec(0.1, 0.3),
				xang: ControlSpec(-pi, pi),
				yang: ControlSpec(-pi, pi),
				zang: ControlSpec(-pi, pi)
			)		
		)
	),
	
	SynthDef(\rwarp, {|out, gate=1, amp, dur=4, buf, str, end, wrp, frq=1.0, wsz, dns, rnd, xang, yang, zang, doneAction = 2|
		var ptr, sig, env, del, shift, a, b, c, d, bf;
		del = Array.geom(4, 0.01, 1.618);
		shift = Array.geom(4, 35/36, 36/35);			
		env = EnvControl.kr(\env, 16);	
		ptr = LFSaw.kr(wrp, 1).range(str, end);
		sig = SndWarp.ar(buf, ptr, frq, wsz, dns, rnd) * 
			EnvGen.kr(env, gate, timeScale: dur, doneAction: doneAction);
		sig = LeakDC.ar(sig ** 0.5);
		sig = Array.fill(4, {|i|
			PitchShift.ar(DelayC.ar(sig, delaytime: del@i), 0.1, shift@i)
		});
		a = BLowShelf.ar(sig@0, 100.0, 0.65, 0.0);
		b = BPeakEQ.ar(sig@1, 600.0, 2.0, 0.0 );
		c = BPeakEQ.ar(sig@2, 2000.0, 2.0, 0.0 );
		d = BHiShelf.ar(sig@3, 7500.0, 1, 0.0 );	
		bf = FoaEncode.ar([a, b, c, d], FoaEncoderMatrix.newAtoB);
		Out.ar(out, FoaTransform.ar(bf, 'rtt', xang, yang, zang) * amp)
	}, metadata:
		(
			type: \proc,
			specs: (
				amp: ControlSpec(0.6, 2.0),
				str: ControlSpec(0.0, 0.3),
				end: ControlSpec(0.7, 1.0),
				wrp: ControlSpec(0.001, 0.01),
				wsz: ControlSpec(0.01, 0.2),
				dns: ControlSpec(4, 8),
				rnd: ControlSpec(0.001, 0.1),
				xang: ControlSpec(-pi, pi),
				yang: ControlSpec(-pi, pi),
				zang: ControlSpec(-pi, pi)
			)
		)
	)
);