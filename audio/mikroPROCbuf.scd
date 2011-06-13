(

	bufplay:	(
		def: SynthDef(\bufplay, {|out, buf, amp, rate, xang, yang, zang, gate=1|
			var sig, a, b, c, d, del, amps, w, x, y, z, env;
			env = EnvControl.kr(\env, 16);
			del = Array.geom(4, 0.008, 1.618);
			amps = Array.geom(4, 1.0, 0.918);
			sig = PlayBuf.ar(1, buf, rate, loop: 1) * EnvGen.kr(env, gate, doneAction: 2);
			a = sig;
			b = DelayN.ar(sig, 0.1, del[1], amps[1]);
			c = DelayN.ar(sig, 0.1, del[2], amps[2]);
			d = DelayN.ar(sig, 0.1, del[3], amps[3]);
			#w, x, y, z = A2B.ar(a, b, c, d);
			Out.ar(out, AtkRotateXYZ.ar(w, x, y, z, xang, yang, zang) * amp)
		}).add,
		
		specs: (
			amp: ControlSpec(0.5, 1.0),
			rate: ControlSpec(1, 1),
			xang: ControlSpec(-pi, pi),
			yang: ControlSpec(-pi, pi),
			zang: ControlSpec(-pi, pi)
		)
		
	),
	
	bufmod: (
		def: SynthDef(\bufmod, {|out, buf, freqc, bufm, freqm, wsz, pch, dur,
				amp, wrate, pd, td, maxdel=0.5, xang, yang, zang, gate=1|
			var sig, bf, winsize, env, a, b, c, d, del, shift, w, x, y, z;
			del = ArrayControl.kr(\delays, 4, 0);
			shift = ArrayControl.kr(\shifts, 4, 1);	
			env = EnvControl.kr(\env, 16);
			sig = PitchShift.ar(Osc.ar(buf, freqc, Osc.ar(bufm, freqm)), 
				wsz, pch, pd, td) * EnvGen.kr(env, gate, timeScale: dur, doneAction: 2);
			#a, b, c, d = Array.fill(4, {|i|
				PitchShift.ar(DelayN.ar(sig, maxdel, del[i]), 0.1, shift[i]);
			});	
			#w, x, y, z = A2B.ar(a, b, c, d);
			Out.ar(out, AtkRotateXYZ.ar(w, x, y, z, xang, yang, zang) * amp);
		}),
		
		specs: (
			freqc: ControlSpec(0.125, 2, step: 0.125), 
			freqm: ControlSpec(2, 0.125, step: 0.125),
			wsz: ControlSpec(0.01, 0.2),
			pch: ControlSpec(0.125, 2.0, step: 0.125),
			amp: ControlSpec(0.5, 1.0),
			wrate: ControlSpec(2, 16, step: 1),
			pd: ControlSpec(0.0, 0.6),
			td: ControlSpec(0.0, 0.6),
			xang: ControlSpec(-pi, pi),
			yang: ControlSpec(-pi, pi),
			zang: ControlSpec(-pi, pi)			
		),

		array: (
			delays: Array.geom(4, 0.01, 1.618),
			shifts: Array.geom(4, 35/36, 36/35)
		)

	),
	
	tyhi: (
		def: SynthDef(\tyhi, {|out, in, gate = 1.0, amp = 1.0, warp = 0.01, stf, enf, buf, 
				rand, grenv = -1, dur=4, tdur, maxdel=0.2, xang, yang, zang|
		
			var sig, w, x, y, z, point, trig, input, freqs, actr, a, b, c, d, del, shift;
			del = ArrayControl.kr(\delays, 4, 0);
			shift = ArrayControl.kr(\shifts, 4, 1);	
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
					SinOsc.kr(Rand(0.5, 3), 0, 5, 10), 
					LFPar.kr(rrand(1, 4), rrand(0, pi), LFSaw.kr(5, 0, 1.5, 2), 5)
				]), 
				rand) * EnvGen.kr(EnvControl.kr(\env, 16), gate, timeScale: dur, doneAction: 2);
			sig = sig + (Reverb.ar(sig, 20) * LFNoise0.kr(LFNoise0.kr(0.3, 1.0, 2.0), 
				0.3, 0.3).floor);
			#a, b, c, d = Array.fill(4, {|i|
				PitchShift.ar(DelayN.ar(sig, maxdel, del[i]), 0.1, shift[i]);
			});	
			#w, x, y, z = A2B.ar(a, b, c, d);
			Out.ar(out, AtkRotateXYZ.ar(w, x, y, z, xang, yang, zang) * amp);
		}),
		
		specs: (
			amp: ControlSpec(0.5, 2.0),
			warp: ControlSpec(0.005, 0.1),
			stf: ControlSpec(0.5, 2.0, step: 0.25),
			enf: ControlSpec(0.5, 2.0, step: 0.125),
			rand: ControlSpec(0.0, 0.01),
			tdur: ControlSpec(0.1, 0.3),
			xang: ControlSpec(-pi, pi),
			yang: ControlSpec(-pi, pi),
			zang: ControlSpec(-pi, pi)
		),
		
		array: (
			delays: Array.geom(4, 0.01, 1.618),
			shifts: Array.geom(4, 35/36, 36/35)
		)
				
	),
	
//	swarp: (
//		def: SynthDef(\swarp, {|out, gate=1, amp, dur=4, buf, str, end, wrp, frq, wsz, dns, rnd, 
//				xang, yang, zang, doneAction = 2|
//			var ptr, sig, env, del, a, b, c, d, w, x, y, z;
//			del = ArrayControl.kr(\del, 4, 1);
//			env = EnvControl.kr(\env, 16);	
//			ptr = LFSaw.kr(wrp, 1).range(str, end);
//			sig = SndWarp.ar(buf, ptr, frq, wsz, dns, rnd) * 
//				EnvGen.kr(env, gate, timeScale: dur, doneAction: doneAction);
//			sig = LeakDC.ar(sig ** 0.5);
//			sig = Array.fill(4, {|i|
//				DelayC.ar(sig, delaytime: del@i)
//			});
//			 a = BLowShelf.ar(sig@0, 100.0, 0.65, 0.0);
//			 b = BPeakEQ.ar(sig@1, 600.0, 2.0, 0.0 );
//			 c = BPeakEQ.ar(sig@2, 2000.0, 2.0, 0.0 );
//			 d = BHiShelf.ar(sig@3, 7500.0, 1, 0.0 );	
//			 #w, x, y, z = A2B.ar(a, b, c, d);
//			Out.ar(out, AtkRotateXYZ.ar(w, x, y, z, xang, yang, zang) * amp);
//		}),
//		
//		specs: (
//			amp: ControlSpec(0.4, 0.8),
//			str: ControlSpec(0.0, 0.0),
//			end: ControlSpec(0.2, 0.5),
//			wrp: ControlSpec(0.001, 0.01),
//			frq: ControlSpec(0.125, 2.0, step: 0.125),
//			wsz: ControlSpec(0.01, 0.2),
//			dns: ControlSpec(8, 1),
//			rnd: ControlSpec(0.0, 0.05),
//			xang: ControlSpec(-pi, pi),
//			yang: ControlSpec(-pi, pi),
//			zang: ControlSpec(-pi, pi)
//		),
//		
//		array: (
//			del: Array.geom(4, 0.01, 1.618)
//		)
//	),
	
	rwarp: (
		def: SynthDef(\rwarp, {|out, gate=1, amp, dur=4, buf, str, end, wrp, frq, wsz, dns, rnd, 
				xang, yang, zang, doneAction = 2|
			var ptr, sig, env, del, a, b, c, d, w, x, y, z;
			del = ArrayControl.kr(\del, 4, 1);
			env = EnvControl.kr(\env, 16);	
			ptr = LFSaw.kr(wrp, 1).range(str, end);
			sig = SndWarp.ar(buf, ptr, frq, wsz, dns, rnd) * 
				EnvGen.kr(env, gate, timeScale: dur, doneAction: doneAction);
			sig = LeakDC.ar(sig ** 0.5);
			sig = Array.fill(4, {|i|
				DelayC.ar(sig, delaytime: del@i)
			});
			a = BLowShelf.ar(sig@0, 100.0, 0.65, 0.0);
			b = BPeakEQ.ar(sig@1, 600.0, 2.0, 0.0 );
			c = BPeakEQ.ar(sig@2, 2000.0, 2.0, 0.0 );
			d = BHiShelf.ar(sig@3, 7500.0, 1, 0.0 );	
			#w, x, y, z = A2B.ar(a, b, c, d);
			Out.ar(out, AtkRotateXYZ.ar(w, x, y, z, xang, yang, zang) * amp);
		}),
		
		specs: (
			amp: ControlSpec(0.6, 1.0),
			str: ControlSpec(0.0, 0.0),
			end: ControlSpec(1.0, 1.0),
			wrp: ControlSpec(0.001, 0.01),
			frq: ControlSpec(0.25, 2.0, step: 0.125),
			wsz: ControlSpec(0.01, 0.2),
			dns: ControlSpec(4, 0.5, step: 0.5),
			rnd: ControlSpec(0.0, 0.1),
			xang: ControlSpec(-pi, pi),
			yang: ControlSpec(-pi, pi),
			zang: ControlSpec(-pi, pi)
		),
		
		array: (
			del: Array.geom(4, 0.01, 1.618)
		)
	)
	
)