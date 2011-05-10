(

	bufplay:	(
		def: SynthDef(\bufplay, {|out, buf, amp, xang, yang, zang, gate=1|
			var sig, a, b, c, d, del, amps, w, x, y, z, env;
			env = EnvControl.kr;
			del = ArrayControl.kr(\delay, 4, 1);
			amps = ArrayControl.kr(\amps, 4, 1);
			sig = PlayBuf.ar(1, buf, -1, loop: 1) * EnvGen.kr(env, gate, doneAction: 2);
			a = sig;
			b = DelayN.ar(sig, 0.1, del[1], amps[1]);
			c = DelayN.ar(sig, 0.1, del[2], amps[2]);
			d = DelayN.ar(sig, 0.1, del[3], amps[3]);
			#w, x, y, z = A2B.ar(a, b, c, d);
			Out.ar(out, AtkRotateXYZ.ar(w, x, y, z, xang, yang, zang) * amp)
		}).add,
		
		specs: (
			amp: ControlSpec(0.3, 0.6),
			xang: ControlSpec(-pi, pi),
			yang: ControlSpec(-pi, pi),
			zang: ControlSpec(-pi, pi)
		),
		
		array: (
			delays: Array.geom(4, 0.008, 1.618),
			amps: Array.geom(4, 1.0, 0.918)
		)
	),

	pch: (
		def: SynthDef(\pch, {|out = 0, in, buf, amp, start, winSize, shift, pdisp, tdisp, pow, 
			dur=4, revamp, deltime, gate = 1.0, xang, yang, zang|
			var sig, w, x, y, z, point, input, env, a, b, c, d, freqs, bws, eqf, eqr, eqdb;
			eqf = ArrayControl.kr(\eqf, 4, 1);
			eqr = ArrayControl.kr(\eqr, 4, 1);
			eqdb = ArrayControl.kr(\eqdb, 4, 0);	
			env = EnvControl.kr;
			sig = DelayC.ar(
				PitchShift.ar(
					PlayBuf.ar(
						1, 
						buf,
						LFNoise1.kr(LFNoise0.kr(10, 10, 20), 0.01, 1.0),
						Dust.kr(start),
						LFNoise0.kr(start, 0, BufFrames.kr(buf)),
						1.0
					) ** pow,
					winSize, 
					LFNoise2.kr(LFNoise0.kr(1, 1, 2), shift, 1.0),
					pdisp,
					tdisp,
					0.5 + (In.ar(in) * LFPulse.kr(2, 0, 0.5, 0.25, 0.5))
				), 0.5, deltime
			) * EnvGen.kr(env, gate, timeScale: dur, doneAction: 2);
			sig = sig + Reverb.ar(sig * revamp, Rand(2, 4));
			a = BLowShelf.ar(sig, eqf@0, eqr@0, eqdb@0 );
			b = BPeakEQ.ar(sig, eqf@1, eqr@1, eqdb@1 );
			c = BPeakEQ.ar(sig, eqf@2, eqr@2, eqdb@2 );
			d = BHiShelf.ar(sig, eqf@3, eqr@3, eqdb@3 );
			#w, x, y, z = A2B.ar(a, b, c, d);
			Out.ar(out, AtkRotateXYZ.ar(w, x, y, z, xang, yang, zang))
		}),
		
		specs: (
			amp: ControlSpec(0.4, 0.8),
			start: ControlSpec(0.2, 0.6),
			winSize: ControlSpec(0.01, 0.2),
			shift: ControlSpec(0.5, 0.1),
			pdisp: ControlSpec(0.0, 0.5),
			tdisp: ControlSpec(0.5, 0.0),
			pow: ControlSpec(1.0, 1.5),
			revamp: ControlSpec(0.05, 0.5),
			deltime: ControlSpec(0.02, 0.5),
			xang: ControlSpec(-pi, pi),
			yang: ControlSpec(-pi, pi),
			zang: ControlSpec(-pi, pi)			
		),
		
		array: (
			eqf: Array.geom(4, 300, 3),
			eqr: [0.6, 2, 2, 1],
			eqdb: [0, -3, -5, 0]
		)
	),
	
	bufmod: (
		def: SynthDef(\bufmod, {|out, buf, freqc, bufm, freqm, wsz, which = 0, pch, 
				amp, wrate, pd, td, maxdel=0.5, xang, yang, zang, gate=1|
			var sig, bf, winsize, env, a, b, c, d, del, shift, w, x, y, z;
			del = ArrayControl.kr(\delays, 4, 0);
			shift = ArrayControl.kr(\shifts, 4, 1);	
			env = EnvControl.kr;
			sig = PitchShift.ar(Osc.ar(buf, freqc, Osc.ar(bufm, freqm)), 
				wsz, pch, pd, td) * EnvGen.kr(env, gate, doneAction: 2);
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
			which: ControlSpec(0, 1, step: 1),
			pch: ControlSpec(0.125, 2.0, step: 0.125),
			amp: ControlSpec(0.3, 1.0),
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
				rand, grenv = -1, dur=4, tdur, maxdel=0.2|
		
			var sig, w, x, y, z, point, trig, input, freqs, actr, a, b, c, d, del, shift;
			var xang, yang, zang;
			del = ArrayControl.kr(\delays, 4, 0);
			shift = ArrayControl.kr(\shifts, 4, 1);	
			input = In.ar(in);
			actr = Slope.kr(Amplitude.kr(input)) > 0.2;
			trig = Trig.kr(actr, tdur);
			xang = EnvGen.kr(EnvControl.kr(\xang), trig, timeScale: tdur);
			yang = EnvGen.kr(EnvControl.kr(\yang), trig, timeScale: tdur);
			zang = EnvGen.kr(EnvControl.kr(\zang), trig, timeScale: tdur);
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
				rand) * EnvGen.kr(Env([0, 1, 1, 0], [0.1, 0.6, 0.3], \sine, 2, 1), 
					gate, timeScale: dur, doneAction: 2);
			sig = sig + (Reverb.ar(sig, 20) * LFNoise0.kr(LFNoise0.kr(0.3, 1.0, 2.0), 
				0.3, 0.3).floor);
			#a, b, c, d = Array.fill(4, {|i|
				PitchShift.ar(DelayN.ar(sig, maxdel, del[i]), 0.1, shift[i]);
			});	
			#w, x, y, z = A2B.ar(a, b, c, d);
			Out.ar(out, AtkRotateXYZ.ar(w, x, y, z, xang, yang, zang));
		}),
		
		specs: (
			amp: ControlSpec(1.0, 0.6),
			warp: ControlSpec(0.005, 0.1),
			stf: ControlSpec(0.5, 2.0, step: 0.25),
			enf: ControlSpec(0.5, 2.0, step: 0.125),
			rand: ControlSpec(0.0, 0.01),
			tdur: ControlSpec(0.1, 0.3)
		),
		
		array: (
			delays: Array.geom(4, 0.01, 1.618),
			shifts: Array.geom(4, 35/36, 36/35)
		),
		
		envs: (
			xang:  {|val| 
				var points, levels, times, curves, rot;
				rot = ControlSpec(-pi, pi).map(val);
				points = ControlSpec(2, 6, step: 1).map(val);
				levels = Array.rand(points, rot.neg, rot);
				times = (1 / (points - 1) ! (points - 1));
				curves = (ControlSpec(-4, 4).map(1 - val) ! points - 1) * [1, -1];
				Env(levels, times, curves)
			},
			yang: {|val| 
				var points, levels, times, curves, rot;
				rot = ControlSpec(-pi, pi).map(val);
				points = ControlSpec(2, 6, step: 1).map(val);
				levels = Array.rand(points, rot.neg, rot);
				times = (1 / (points - 1) ! (points - 1));
				curves = (ControlSpec(-4, 4).map(1 - val) ! points - 1) * [1, -1];
				Env(levels, times, curves)
			},
			zang: {|val| 
				var points, levels, times, curves, rot;
				rot = ControlSpec(-pi, pi).map(val);
				points = ControlSpec(2, 6, step: 1).map(val);
				levels = Array.rand(points, rot.neg, rot);
				times = (1 / (points - 1) ! (points - 1));
				curves = (ControlSpec(-4, 4).map(1 - val) ! points - 1) * [1, -1];
				Env(levels, times, curves)
			}
		)
		
	),
	
	swarp: (
		def: SynthDef(\swarp, {|out, gate=1, amp, dur=4, buf, str, end, wrp, frq, wsz, dns, rnd, 
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
			amp: ControlSpec(0.4, 0.8),
			str: ControlSpec(0.0, 0.0),
			end: ControlSpec(0.2, 0.5),
			wrp: ControlSpec(0.001, 0.01),
			frq: ControlSpec(0.125, 2.0, step: 0.125),
			wsz: ControlSpec(0.01, 0.2),
			dns: ControlSpec(8, 1),
			rnd: ControlSpec(0.0, 0.05),
			xang: ControlSpec(-pi, pi),
			yang: ControlSpec(-pi, pi),
			zang: ControlSpec(-pi, pi)
		),
		
		array: (
			del: Array.geom(4, 0.01, 1.618)
		)
	),
	
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
		}).add,
		
		specs: (
			amp: ControlSpec(0.3, 0.7),
			str: ControlSpec(0.0, 0.0),
			end: ControlSpec(0.2, 0.2),
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