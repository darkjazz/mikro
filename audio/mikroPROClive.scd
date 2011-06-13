(
	fbgverb: (
		def: SynthDef(\fbgverb, {|out, in, gate = 1.0, i_wrp, frq, wsz, dns, rnd, amp, rmp, rtm, 
				xang, yang, zang|
			var bufs, recs, ptrs, phases, deltimes, output, trigs, input, w, x, y, z, ampctr;
			var freqarr, amparr, ringarr;
			deltimes = [0, 1 / i_wrp * 0.5, 1 / i_wrp];
			bufs = Array.fill(3, { LocalBuf(SampleRate.ir * 2) });
			ptrs = Array.fill(3, {|i| LFSaw.kr(i_wrp, 0, 0.5, 0.5) });
			trigs = Array.fill(3, {|i| DelayN.kr(Impulse.kr(i_wrp * (2 / 3)), 
				deltimes@i, deltimes@i) });
			input = In.ar(in);
			ampctr = Amplitude.kr(input).explin(0.0001, 1.0, 0.1, 1.0);
			recs = Mix.fill(3, {|i|
				RecordBuf.ar(input, bufs@i, loop:0.0, trigger: trigs@i);
			});
			freqarr = [
				Array.geom(5, exp(1)**4, 3 ),
				Array.geom(5, pi**3, 4.5),
				Array.geom(5, (144/89)**8, 3.3 )
			];
			amparr = Array.fill(3, {|i|
				freqarr[i].collect({|ifr| AmpCompA.ir(ifr) })
			});
			ringarr = Array.fill(3, {|i|
				amparr[i].collect({|iamp| iamp ** 0.5 })
			});
			output = Mix.fill(3, {|i|
				var wrp = Warp1.ar(1, bufs@i, ptrs@i, frq, wsz, -1, dns, rnd);
				wrp + (Klank.ar(`[freqarr[i], amparr[i], ringarr[i]], 
					Reverb.ar(wrp * rmp, rtm)) ** 2.0 * LFSaw.kr(12).range(ampctr, 1.0))
					* EnvGen.kr(
						Env([0.0,1.0,1.0,0.0],[0.3,0.4,0.3],\sine, 0, 3),
						trigs.rotate(-1)@i, timeScale: 1.0 / i_wrp
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
		}).add,
		specs: (
			i_wrp: ControlSpec(0.01, 0.1),
			frq: ControlSpec(0.25, 2.0, step: 1/4),
			wsz: ControlSpec(0.01, 0.2),
			dns: ControlSpec(1, 10),
			rnd: ControlSpec(0, 0.01),
			amp: ControlSpec(0.3, 1.0),
			rmp: ControlSpec(0.05, 0.01),
			rtm: ControlSpec(3.0, 10.0),
			xang: ControlSpec(-pi, pi),
			yang: ControlSpec(-pi, pi),
			zang: ControlSpec(-pi, pi)
		)
	),
	
	latch: (
		def: SynthDef(\latch, {|out, in, th, eb1, eb2, rt, damp=0.5, bw=0.5, sp, dry, early, tail, 				gate=1, quant, index, amp, xang, yang, zang|
			
			var input, freq, trig, fft, gtrig, rL, rR, w, x, y, z, env, sig, pitch, a, b, c, d;
			env = Control.names([\env]).kr(Env.newClear(8).asArray);
			input = In.ar(in);
			pitch = Pitch.kr(input)[0];
			fft = FFT(LocalBuf(512), input);
			trig = Trig.kr(Onsets.kr(fft, th), quant);
			freq = Latch.ar(pitch, trig);
			gtrig = Dust.kr(SinOsc.kr(LFNoise2.kr(0.5)).range(8, 64));
			sig = FMGrain.ar(
				gtrig, 
				Lag.kr(Amplitude.kr(input), 0.1).linlin(0.0, 1.0, 0.001, 0.01), 
				Select.kr(TIRand.kr(0, 6, gtrig), 
					freq * Array.geom(7, 0.125, 2**(1/21) ) * (1..7)), 
				freq,
				index,
				EnvGen.kr(Env([1, 1, 0], [0.5, 0.5], \sine), trig, timeScale: TRand.kr(0.3, 3.0, trig))
			);
			#rL, rR = GVerb.ar(sig + Dust2.ar(pitch), 50, rt, damp, bw, sp, dry, early, tail, 50)
				* EnvGen.kr(env, gate, doneAction: 2);
			a = BLowShelf.ar(rL, 100, 0.5, 0.5);
			b = BPeakEQ.ar(rR, 800, 5.0, -16);
			c = BHiShelf.ar(rL, 10000, 1.0, 1.0);
			d = BPeakEQ.ar(rR, 3000, 3.0, -8);
			#w, x, y, z = A2B.ar(a, b, c, d);
			Out.ar(out, AtkRotateXYZ.ar(w, x, y, z, xang, yang, zang))
		}),
		specs: (
			th: ControlSpec(-40.dbamp, -20.dbamp),
			rt: ControlSpec(0.5, 5),
			sp: ControlSpec(5, 20),
			dry: ControlSpec(0.2, 0.5),
			early: ControlSpec(0.05, 0.5),
			tail: ControlSpec(0.1, 0.2),
			amp: ControlSpec(0.4, 0.05),
			quant: ControlSpec(0.125, 1.0, step: 0.125),
			index: ControlSpec(20, 3),
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
	),
	
	arhythmic: (
		def: SynthDef(\arhythmic, {|out, in, gate = 1, drB, amp, xang, yang, zang|
			var sig, trigs, fft, beat, input, sB, pch, env, shift, del, ampctr;
			var w, x, y, z, a, b, c, d, trigB;
			shift = Array.geom(4, 35/36, 36/35);
			del = Array.geom(4, 0.005, 1.618);
			env = EnvControl.kr;
			input = In.ar(in);
			pch = Pitch.kr(input).first;
			fft = FFT(LocalBuf(1024), input);
			ampctr = Lag.kr(Amplitude.kr(input), 0.25);
			trigB = Trig.kr(Onsets.kr(fft, -40.dbamp), 0.25);
			sB = Gendy3.ar(2, 5, 0.5, 0.5, pch, 0.5, 0.5, 21, 21)
				* EnvGen.kr(Env([1, 1, 0], [0.25, 0.75], \sine), trigB, timeScale: drB);
			sB = GVerb.ar(sB * ampctr, LFSaw.kr(LFSaw.kr(1).range(0.5, 2)).range(4, 20), 
				Latch.kr(ampctr, trigB) * 20).first;
			sB = DelayN.ar(CombC.ar(sB, 0.25, 0.25, 1), 0.5, LFSaw.kr(1.5).range(0.0625, 0.5).round(0.0625));
			#w, x, y, z = A2B.ar(
				*Array.fill(4, {|i|
					PitchShift.ar(DelayN.ar(sB, 0.1, del[i]), 0.1, shift[i])
				})
			) * EnvGen.kr(env, gate, doneAction: 2);
			Out.ar(out, AtkRotateXYZ.ar(w, x, y, z, xang, yang, zang) * amp)
		}).add,
		
		specs: (
			drB: ControlSpec(0.0625, 0.25, step: 0.0625),
			amp: ControlSpec(0.2, 0.5),
			xang: ControlSpec(-0.5pi, 1.5pi),
			yang: ControlSpec(2pi, 0),
			zang: ControlSpec(0.5pi, -1.5pi)
		)
	) 	
);