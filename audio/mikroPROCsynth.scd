(
	kck: (
		def: SynthDef(\kck, {|ou, ef, fr, dr, xa, ya, za, ea, am|
			var sig, env, w, x, y, z, del, amp;
			env = EnvControl.kr(\env, 12);
			del = ArrayControl.kr(\delay, 4, 1);
			amp = ArrayControl.kr(\amp, 4, 1);
			sig = BLowPass.ar(
				Mix(
					SinOsc.ar(
						Array.series(5, fr, 10) * LFNoise0.ar(1000.0).range(35/36, 36/35), 
						0.5pi 
					)
				),
				fr * 2,
				1.0
			) * EnvGen.kr(env, timeScale: dr, doneAction: 2);
			Out.ar(ef, sig * ea);
			#w, x, y, z = A2B.ar(*Array.fill(4, {|i|
				DelayC.ar(sig, 0.1, del[i], amp[i])
			}));
			Out.ar(ou, AtkRotateXYZ.ar(w, x, y, z, xa, ya, za) * am)
		}),
		
		specs: (
			ea: ControlSpec(0.01, 0.05),
			am: ControlSpec(0.7, 2),			
			xa: ControlSpec(-pi, pi),
			ya: ControlSpec(-pi, pi),
			za: ControlSpec(-pi, pi)
		),
		array: (
			delay: Array.geom(4, 0.008, 1.618),
			amp: Array.geom(4, 1.0, 0.918)
		),
		
		frange: (min: 40, max: 160)
		
	),

	snr: (	
		def: SynthDef(\snr, {|ou, ef, fr, dr, am, ea, xa, ya, za|
			var sig, env, w, x, y, z, del, amp;
			env = EnvControl.kr(size: 12);
			del = ArrayControl.kr(\delay, 4, 1);
			amp = ArrayControl.kr(\amp, 4, 1);
			sig = Dust2.ar(fr) + BPF.ar(WhiteNoise.ar, Line.kr(fr*1.5, fr*0.667, dr), 0.5) 
				* EnvGen.kr(env, timeScale: dr, doneAction: 2);
			Out.ar(ef, sig * ea);
			#w, x, y, z = A2B.ar(*Array.fill(4, {|i|
				DelayC.ar(sig, 0.1, del[i], amp[i])
			}));
			Out.ar(ou, AtkRotateXYZ.ar(w, x, y, z, xa, ya, za) * am)
		}),
		
		specs: (
			am: ControlSpec(10, 20, step: 1),
			ea: ControlSpec(0.1, 0.2),
			xa: ControlSpec(-pi, pi),
			ya: ControlSpec(-pi, pi),
			za: ControlSpec(-pi, pi)			
		),
		array: (
			delay: Array.geom(4, 0.008, 1.618),
			amp: Array.geom(4, 1.0, 0.918)
		),
		
		frange: (min: 200, max: 1000)
			
	),
	
	hh:	(
		def: SynthDef(\hh, {|ou, ef, dr, fr, xa, ya, za, am, ea|
			var sig, env, w, x, y, z, del, amp;
			env = EnvGen.kr(EnvControl.kr(size: 12), timeScale: dr, doneAction: 2);
			del = ArrayControl.kr(\delay, 4, 1);
			amp = ArrayControl.kr(\amp, 4, 1);
			sig = RHPF.ar(PinkNoise.ar, fr, 0.3) * env;
			Out.ar(ef, sig * ea);
			#w, x, y, z = A2B.ar(*Array.fill(4, {|i|
				DelayC.ar(sig, 0.1, del[i], amp[i])
			}));
			Out.ar(ou, AtkRotateXYZ.ar(w, x, y, z, xa, ya, za) * am)
		}),
	
		specs: (
			am: ControlSpec(20, 30),
			ea: ControlSpec(2.0, 3.0),
			xa: ControlSpec(-pi, pi),
			ya: ControlSpec(-pi, pi),
			za: ControlSpec(-pi, pi)			
		),
		array: (
			delay: Array.geom(4, 0.008, 1.618),
			amp: Array.geom(4, 1.0, 0.918)
		),
		
		frange: (min: 1500, max: 3000)

	),
	
	bss: (
		def: SynthDef(\bss, {|ou, ef, fr, dr, xa, ya, za, am, ea|
			var env, sig, w, x, y, z, del, amp;
			env = EnvControl.kr(size: 12);
			del = ArrayControl.kr(\delay, 4, 1);
			amp = ArrayControl.kr(\amp, 4, 1);
			sig = SinOsc.ar(fr * 
				LFNoise2.ar(SinOsc.ar(10000).range(5000, 10000)).range(35/36, 36/35), 
				SinOsc.kr(2.25, 0, pi, pi), LFSaw.kr(4).range(1, 10)).distort
				* EnvGen.kr(env, timeScale: dr, doneAction: 2);
			sig = Reverb.ar(sig * 0.1, 3) + sig;
			sig = Compander.ar(sig, sig, 0.2, 1.0, 0.01);
			Out.ar(ef, sig * ea);
			#w, x, y, z = A2B.ar(*Array.fill(4, {|i|
				DelayC.ar(sig, 0.1, del[i], amp[i])
			}));
			Out.ar(ou, AtkRotateXYZ.ar(w, x, y, z, xa, ya, za) * am)
		}),
		
		specs: (
			am: ControlSpec(3.0, 5.0),
			ea: ControlSpec(0.3, 0.5),
			xa: ControlSpec(-pi, pi),
			ya: ControlSpec(-pi, pi),
			za: ControlSpec(-pi, pi)			
		),
		
		array: (
			delay: Array.geom(4, 0.008, 1.618),
			amp: Array.geom(4, 1.0, 0.918)
		),
		
		frange: (min: 40, max: 160)

	),
	
	clck: (
		def: SynthDef(\clck, {|ou, ef, am, xa, ya, za, fr, dr, bt, ea|
			var sig, w, x, y, z, del, amp;
			del = ArrayControl.kr(\delay, 4, 1);
			amp = ArrayControl.kr(\amp, 4, 1);
			sig = BPF.ar(
				VarSaw.ar(15000, 0.0, 0.1, Decay.ar(Impulse.ar(bt), 0.001)),
				fr,
				0.9,
				25 * LFNoise1.ar(8).range(0, 1)
			).fold(-1, 1);
			sig = sig * EnvGen.kr(EnvControl.kr(size: 12), timeScale: dr, doneAction: 2);
			Out.ar(ef, sig * ea);
			#w, x, y, z = A2B.ar(*Array.fill(4, {|i|
				DelayC.ar(sig, 0.1, del[i], amp[i])
			}));
			Out.ar(ou, AtkRotateXYZ.ar(w, x, y, z, xa, ya, za) * am)
		}),
		
		specs: (
			am: ControlSpec(6.0, 10.0, step: 1),
			bt: ControlSpec(4, 8, step: 1),
			ea: ControlSpec(0.05, 0.2),
			xa: ControlSpec(-pi, pi),
			ya: ControlSpec(-pi, pi),
			za: ControlSpec(-pi, pi)			
		),

		array: (
			delay: Array.geom(4, 0.008, 1.618),
			amp: Array.geom(4, 1.0, 0.918)
		),
		
		frange: (min: 1000, max: 20000)
		
	),
	
	nzsnr: (
		def: SynthDef(\nzsnr, {|ou, am, xa, ya, za, fr, dr|
			var sig, env, w, x, y, z, del, amp;
			del = ArrayControl.kr(\delay, 4, 1);
			amp = ArrayControl.kr(\amp, 4, 1);
			env = EnvGen.kr(EnvControl.kr(size: 12), timeScale: dr, doneAction: 2);
			sig = Dust.ar(fr) * SinOsc.ar(fr) * env;
			#w, x, y, z = A2B.ar(*Array.fill(4, {|i|
				DelayC.ar(sig, 0.1, del[i], amp[i])
			}));
			Out.ar(ou, AtkRotateXYZ.ar(w, x, y, z, xa, ya, za) * am)
		}),
		
		specs: (
			am: ControlSpec(5, 10),
			xa: ControlSpec(-pi, pi),
			ya: ControlSpec(-pi, pi),
			za: ControlSpec(-pi, pi)
		),

		array: (
			delay: Array.geom(4, 0.008, 1.618),
			amp: Array.geom(4, 1.0, 0.918)
		),
		
		frange: (min: 500, max: 2000)
	),
	
	pnk: (
		def: SynthDef(\pnk, {|ou, az, dr, fr, xa, ya, za, am|
			var sig, env, w, x, y, z, del, amp;
			env = EnvGen.kr(EnvControl.kr(size: 12), timeScale: dr, doneAction: 2);
			del = ArrayControl.kr(\delay, 4, 1);
			amp = ArrayControl.kr(\amp, 4, 1);
			sig = RLPF.ar(PinkNoise.ar, fr).clip(-1, 1) * env;
			#w, x, y, z = A2B.ar(*Array.fill(4, {|i|
				DelayC.ar(sig, 0.1, del[i], amp[i])
			}));
			Out.ar(ou, AtkRotateXYZ.ar(w, x, y, z, xa, ya, za) * am)
		}),
		
		specs: (
			am: ControlSpec(3.0, 6.0),
			xa: ControlSpec(-pi, pi),
			ya: ControlSpec(-pi, pi),
			za: ControlSpec(-pi, pi)
		),

		array: (
			delay: Array.geom(4, 0.008, 1.618),
			amp: Array.geom(4, 1.0, 0.918)
		),
		
		frange: (min: 500, max: 2000)
		
	),
	
	fmsnth: (
		def: SynthDef(\fmsnth, {|ou, ef, dr, gd, fr, mf, in, az, on, xa, ya, za, am|
			var sig, env, w, x, y, z, del, amp, trg, dev, amps, n = 4;
			del = ArrayControl.kr(\delay, 4, 1);
			amp = ArrayControl.kr(\amp, 4, 1);
			trg = Array.fill(4, { Impulse.kr(1 / (gd * Rand(0.9, 1.1)) ) });
			env = EnvControl.kr(size: 12);
			dev = Array.rand(n, 0.5, 2.0).round(1 - (2**(1/24)));
			amps = Array.geom(n, 1.0, 13 / 21);
			sig = Array.fill(n, {|i|
				var frq = fr * dev[i];
				DelayC.ar(FMGrain.ar(trg[i], gd * TRand.kr(0.9, 1.1, trg[i]), 
					frq, frq * mf, in, amps[i]), 0.1, Rand(0, 0.1))
			}) * EnvGen.kr(env, timeScale: dr, doneAction: 2);
			#w, x, y, z = A2B.ar(*Array.fill(4, {|i|
				DelayC.ar(sig[i], 0.1, del[i], amp[i])
			}));
			Out.ar(ou, AtkRotateXYZ.ar(w, x, y, z, xa, ya, za) * am)
		}),
		
		specs: (
			gd: ControlSpec(0.005, 0.05),
			mf: ControlSpec(0.25, 2.0, step: 0.25),
			in: ControlSpec(6, 24, step: 2),
			am: ControlSpec(1.0, 3.0),
			xa: ControlSpec(-pi, pi),
			ya: ControlSpec(-pi, pi),
			za: ControlSpec(-pi, pi)			
		),
		
		array: (
			delay: Array.geom(4, 0.008, 1.618),
			amp: Array.geom(4, 1.0, 0.918)
		),
		
		frange: (min: 100, max: 1600)
		
	),
	
	hgls: (
	 def: SynthDef(\hgls, {|ou, dr, fr, wd, ws, wr, gr, az, on, xa, ya, za, am|
			var sig, env, w, x, y, z, del, amp;
			del = ArrayControl.kr(\delay, 4, 1);
			amp = ArrayControl.kr(\amp, 4, 1);		
			env = EnvControl.kr(size: 12);
			sig = VarSaw.ar(XLine.kr(fr, fr * 0.5, dr), 0, wd);
			sig = GrainIn.ar(1, Impulse.kr(gr * TRand.kr(1-wr, 1+wr, Impulse.kr(gr))), ws, sig) * 
				EnvGen.kr(env, timeScale: dr, doneAction: 2);
			#w, x, y, z = A2B.ar(*Array.fill(4, {|i|
				DelayC.ar(sig, 0.1, del[i], amp[i])
			}));
			Out.ar(ou, AtkRotateXYZ.ar(w, x, y, z, xa, ya, za) * am)
			
		}),
		
		specs: (
			wd: ControlSpec(0.2, 0.5), 
			ws: ControlSpec(0.01, 0.05), 
			wr: ControlSpec(0.01, 0.05), 
			gr: ControlSpec(8, 12), 
			am: ControlSpec(0.1, 0.4),
			xa: ControlSpec(-pi, pi),
			ya: ControlSpec(-pi, pi),
			za: ControlSpec(-pi, pi)
		),
		
		array: (
			delay: Array.geom(4, 0.008, 1.618),
			amp: Array.geom(4, 1.0, 0.918)
		),
		
		frange: (min: 200, max: 1000)
	
	),
	
	gndy: (
		def: SynthDef(\gndy, {|ou, dr, fr, sf, ef, xa, ya, za, am|
			var sig, w, x, y, z, del, amp;
			del = ArrayControl.kr(\delay, 4, 1);
			amp = ArrayControl.kr(\amp, 4, 1);		
			sig = BPF.ar(Gendy3.ar(freq: XLine.kr(sf, ef, dr)), fr, 10 / fr, 10)
				* EnvGen.kr(EnvControl.kr(size: 12), timeScale: dr, doneAction: 2);
			#w, x, y, z = A2B.ar(*Array.fill(4, {|i|
				DelayC.ar(sig, 0.1, del[i], amp[i])
			}));
			Out.ar(ou, AtkRotateXYZ.ar(w, x, y, z, xa, ya, za) * am)
		}),
		
		specs: (
			ef: ControlSpec(400, 800, step: 2**(1/5)),
			sf: ControlSpec(200, 300, step: 2**(1/12)),
			am: ControlSpec(1.0, 2.0),
			xa: ControlSpec(-pi, pi),
			ya: ControlSpec(-pi, pi),
			za: ControlSpec(-pi, pi)
		),
		
		array: (
			delay: Array.geom(4, 0.008, 1.618),
			amp: Array.geom(4, 1.0, 0.918)
		),
		
		frange: (min: 50, max: 1000)

	),
	
	bpst: (
		def: SynthDef(\bpst, {|ou, dr, fr, xa, ya, za, am|
			var sig, w, x, y, z, del, amp;
			del = ArrayControl.kr(\delay, 4, 1);
			amp = ArrayControl.kr(\amp, 4, 1);
			sig = KmeansToBPSet1.ar(freq: fr) 
			* EnvGen.kr(EnvControl.kr(size: 12), timeScale: dr, doneAction: 2);
			#w, x, y, z = A2B.ar(*Array.fill(4, {|i|
				DelayC.ar(sig, 0.1, del[i], amp[i])
			}));
			Out.ar(ou, AtkRotateXYZ.ar(w, x, y, z, xa, ya, za) * am)
		}),

		specs: (
			am: ControlSpec(1.0, 2.0),
			xa: ControlSpec(-pi, pi),
			ya: ControlSpec(-pi, pi),
			za: ControlSpec(-pi, pi)
		),
		
		array: (
			delay: Array.geom(4, 0.008, 1.618),
			amp: Array.geom(4, 1.0, 0.918)
		),
		
		frange: (min: 10000, max: 40000)
		
	)
	
)