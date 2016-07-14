Routine({
	SynthDef(\funktplay, {|out, buf, rate, amp = 0|
		var sig, del, pch, off;
		pch = Array.geom(4, 35/36**2, 36/35 ).scramble;
		del = Array.geom(3, pi/1000, 1.618).add(0).scramble;
		off = Array.series(4, 0, 2205);
		sig = PlayBuf.ar(1, buf, rate, 1, off, 1);
		#w, x, y, z = FoaEncode.ar(
			Array.fill(4, {|i|
				DelayL.ar(PitchShift.ar(sig[i], 0.1, pch[i]), del[i], del[i]);
			}),
			FoaEncoderMatrix.newAtoB
		);
		Out.ar(out, FoaRTT.ar(w, x, y, z,
			LFNoise1.kr(1/7).range(-pi, pi),
			LFNoise1.kr(1/11).range(-pi, pi),
			LFNoise1.kr(1/5).range(-pi, pi)			
		) * amp)
	}).add;
	
	~funktqueue = List();
	
	~theta = Array.series(9, -pi, 2pi/9);	
	~phi = [0,0.25,0.25.neg].lace(9);
	
	~patchnames = #[kc,cl,hi,sw,ds,nf,pm,dt,gs,aa,bb,cc,dd,ee,ff,gg,hh,ii,xx,xy,xz,yy,yz,yx,zz,zx,zy];

	~funktfuncs = (
		\kc: { Mix(SinOsc.ar([40, 51, 63], 0.5pi)) },
		\cl: { Impulse.ar(1, 10).clip(-0.9, 0.9) },
		\hi: { PinkNoise.ar.clip(-0.9, 0.9) },
		\sw: { Mix(LFSaw.ar([60, 61] + LFSaw.ar([1, 8]).range(20, 80))).clip(-0.9, 0.9) },
		\ds: { BPF.ar(BrownNoise.ar(10).clip(-0.9, 0.9), 200, 0.2, 10) },
		\nf: { VarSaw.ar(IRand(10000, 15000).round(5000), 0.25, 0.01, 20).clip(-0.9, 0.9) },
		\pm: { LFPulse.ar(20 + LFPulse.ar(10)).distort },
		\dt: { Dust2.ar(200, 2, SinOsc.ar(Rand(8000, 16000).round(2**(1/5)))) },
		\gs: { LFGauss.ar(1/60, XLine.kr(0.1, 0.01, 0.2)) },
		
		\aa: { Mix(SinOsc.ar([20, 25, 30, 35], 0.5pi)) },
		\bb: { LFNoise0.ar(1000 + LFNoise0.ar(2500, 10).range(50, 200), 200).tanh },
		\cc: { Mix(SinOsc.ar(SinOsc.ar([1000, 100]).range(20, 200), 0.5pi)) },
		\dd: { Mix(SinOsc.ar(SinOsc.ar([51, 50]).range(20, 80), 0.5pi)) },
		\ee: { Impulse.ar(1, 100).clip(-0.9, 0.9) + Reverb.ar(Dust2.ar(100, 2),50).tanh },
		\ff: { LFSaw.ar(20, 0.5, LFNoise0.ar(10000).range(10, 100)).distort },
		\gg: { Blip.ar(10, 100, 10).clip(-0.9, 0.9) },
		\hh: { SineShaper.ar(SinOsc.ar(200, 0, 200), 0.5) },
		\ii: { SinOsc.ar(2**14) },
		
		\xx: { PlayBuf.ar(1, ~glitchbufs[0], 2.0) },
		\xy: { BufRd.ar(1, ~glitchbufs[1], Phasor.ar(end: 44100 )) },
		\xz: { Warp1.ar(1, ~glitchbufs[2], SinOsc.kr(1).range(0, 1), 0.5, 0.01) },
		\yy: { GrainBuf.ar(1, Dust.ar(2**7), 0.1, ~glitchbufs[3], 1/4) },
		\yz: { OscN.ar(~glitchbufs[4], 2**6, 0, 10) },
		\yx: { WaveTerrain.ar(~glitchbufs[5], LFSaw.ar(20).range(1, 0), LFTri.ar(10).range(0, 1), *44100.sqrt.dup) },
		\zz: { SortBuf.ar(~glitchbufs[6]) },
		\zx: { Mix(TGrains.ar(2, Impulse.ar(40), ~glitchbufs[7], 0.5, 0, 0.01 )) ** 0.5 },
		\zy: { PlayBuf.ar(1, ~glitchbufs[8], 0.5) }
	);
	
	~funktmakedef = {|name, func, env|
		SynthDef(name, {|out, efx, dur = 0.1, amp = 1.0, emp = 0.0, xang, yang, zang| 
			var sig, w, x, y, z;
			sig = SynthDef.wrap(func) * EnvGen.kr(env, levelScale: amp, timeScale: dur, doneAction: 2);
			Out.ar(efx, sig * emp);
			#w, x, y, z = FoaEncode.ar(sig, 
				FoaEncoderMatrix.newDirection(~theta.wrapAt(~patchnames.indexOf(name)), ~phi.wrapAt(~patchnames.indexOf(name)))
			);
			Out.ar(out, FoaRTT.ar(w, x, y, z, xang, yang, zang))
		}).add;		
	};
	
	~funktenvs = (
		\nf: Env.perc(curve: -8),
		\pm: Env([0, 1, 1, 0], [0.3, 0.4, 0.3]),
		\ds: Env.perc(curve: -2),
		\aa: Env.perc(curve: 4),
		\cc: Env.perc(curve: -8),
		\dd: Env([0, 1, 1, 0], [0.3, 0.4, 0.3]),
		\ee: Env.perc(curve: -2),
		\ff: Env([0.01, 1.0, 0.001], [0.8, 0.2]),		
		\default: Env([1, 1, 0], [1, 0])
	);	
	
	~funktfuncs.keysValuesDo({|name, func, env|
		~funktmakedef.value(name, func, ~funktenvs[name] ? ~funktenvs[\default])
	});
		
	SynthDef(\funktrev01, {|out, in|
		var input, sig, dels, w, x, y, z;
		dels = Array.geom(4, 0.01, 1+5.sqrt/2);
		input = In.ar(in);
		sig = GVerb.ar(input, 100, 10, drylevel: 0, earlyreflevel: 1.0, taillevel: 1.0, maxroomsize: 100);
		#w, x, y, z = FoaEncode.ar(Array.fill(4, {|i| DelayN.ar(sig.wrapAt(i), 0.1, dels[i]) }), FoaEncoderMatrix.newAtoB);
		Out.ar(out, 
			AtkRotateXYZ.ar(w, x, y, z, 
				LFNoise1.kr(2.25.reciprocal).range(-pi, pi),
				LFNoise2.kr(4.5.reciprocal).range(-pi, pi),
				LFNoise0.kr(7.reciprocal).range(-pi, pi)
			)
		)
	}).add;	
	
	Server.default.sync;
	
	~funktefxbus = Bus.audio;
	
	~funktpats = (
		\kc: [1, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0],
		\cl: [0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0],
		\hi: [0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0, 0, 0],
		\sw: [0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 1, 0],
		\ds: [0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 1, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0],
		\nf: [0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 1, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0],
		\pm: [0, 0, 0, 0, 0, 1, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0],
		\dt: [0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0],
		\gs: [0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 1, 0, 0, 0],
		
		\aa: [0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0, 0, 0],
		\bb: [1, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0],
		\cc: [0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 1, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0],
		\dd: [0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0],
		\ee: [0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 1, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0],
		\ff: [0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 1, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0],
		\gg: [0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 1, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0],
		\hh: [0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 1, 0, 0, 0,  0, 0, 0, 0, 1, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0],
		\ii: [0, 0, 0, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0],
		
		\xx: [1, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0],
		\xy: [0, 0, 0, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0],
		\xz: [0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 1, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0],
		\yy: [0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  1, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0],
		\yz: [0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 1, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0],
		\yx: [0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 1, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0],
		\zz: [0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 1, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0],
		\zx: [0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 1, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0],
		\zy: [0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 1, 0, 1, 0]
	);
	
	~funktamps = ~funktpats.collect({ (active: 0, amp: 0) });
	
	~funktstreams = (
		\kc: [\dur, Pbrown(1/16, 1/8, 1/64, inf), \emp, 0, \xang, Pxrand([0, pi, -0.5pi, 0.5pi], inf), 
			\yang, Pxrand([0, pi, -0.5pi, 0.5pi], inf), \zang, Pxrand([0, pi, -0.5pi, 0.5pi], inf)
		],
		\cl: [\dur, 0.001, \emp, 0, \xang, Pxrand(Array.series(9, -pi, pi/4), inf), 
			\yang, Pxrand(Array.series(9, -pi, pi/4), inf), \zang, Pxrand(Array.series(9, -pi, pi/4), inf)
		],
		\hi: [\dur, Pwhite(0.025, 0.05, inf), \emp, 0, \xang, Pwhite(-pi, pi, inf), 
			\yang, Pwhite(-pi, pi, inf), \zang, Pwhite(-pi, pi, inf)
		],
		\sw: [\dur, Pseq([0.1, 0.01, 0.05, 0.1, 0.01], inf), \emp, 0, 
			\xang, Pseq([-0.25, 0.75, -0.75, 0.25]*pi, inf), \yang, 0, \zang, 0
		],
		\ds: [\dur, Pwhite(0.01, 0.04, inf), \emp, 0, \xang, Pwhite(-pi, pi, inf), 
			\yang, Pwhite(-pi, pi, inf), \zang, Pwhite(-pi, pi, inf)
		],
		\nf: [\dur, Pbrown(1/32, 1/16, 1/64, inf), \emp, Pseq([0.04, 0.02, 0.0, 0.03, 0.01], inf), 
			\xang, Pseq([-0.25, 0, 0.25, 1, -0.75, 0.75]*pi, inf), \yang, 0, \zang, 0
		],
		\pm: [\dur, Pseq(Array.geom(7, 0.1, 1.1).mirror, inf), \emp, 0, \xang, Pwhite(-pi, pi, inf), 
			\yang, Prand([0, pi, -0.5pi, 0.5pi], inf), \zang, Prand([0, pi, -0.5pi, 0.5pi], inf)
		],
		\dt: [\dur, 0.1, \emp, 0, \xang, Pwhite(-pi, pi, inf), 
			\yang, Pwhite(-pi, pi, inf), \zang, Pwhite(-pi, pi, inf)
		],
		\gs: [\dur, 0.2, \emp, 0, \xang, Pwhite(-pi, pi, inf), 
			\yang, Pwhite(-pi, pi, inf), \zang, Pwhite(-pi, pi, inf)
		],
		
		
		\aa: [\dur, Pbrown(1/16, 1/8, 1/64, inf), \emp, 0, \xang, Pxrand([0, pi, -0.5pi, 0.5pi], inf), 
			\yang, Pxrand([0, pi, -0.5pi, 0.5pi], inf), \zang, Pxrand([0, pi, -0.5pi, 0.5pi], inf)
		],
		\bb: [\dur, 0.001, \emp, 0, \xang, Pxrand(Array.series(9, -pi, pi/4), inf), 
			\yang, Pxrand(Array.series(9, -pi, pi/4), inf), \zang, Pxrand(Array.series(9, -pi, pi/4), inf)
		],
		\cc: [\dur, Pwhite(0.025, 0.05, inf), \emp, 0, \xang, Pwhite(-pi, pi, inf), 
			\yang, Pwhite(-pi, pi, inf), \zang, Pwhite(-pi, pi, inf)
		],
		\dd: [\dur, Pseq([0.25, 0.125, 0.375, 0.125, 0.25], inf), \emp, 0, 
			\xang, Pseq([-0.25, 0.75, -0.75, 0.25]*pi, inf), \yang, 0, \zang, 0
		],
		\ee: [\dur, Pwhite(0.01, 0.04, inf), \emp, 0, \xang, Pwhite(-pi, pi, inf), 
			\yang, Pwhite(-pi, pi, inf), \zang, Pwhite(-pi, pi, inf)
		],
		\ff: [\dur, Pbrown(1/32, 1/16, 1/64, inf), \emp, Pseq([0.04, 0.02, 0.0, 0.03, 0.01], inf), 
			\xang, Pseq([-0.25, 0, 0.25, 1, -0.75, 0.75]*pi, inf), \yang, 0, \zang, 0
		],
		\gg: [\dur, Pseq(Array.geom(7, 0.1, 1.1).mirror, inf), \emp, 0, \xang, Pwhite(-pi, pi, inf), 
			\yang, Prand([0, pi, -0.5pi, 0.5pi], inf), \zang, Prand([0, pi, -0.5pi, 0.5pi], inf)
		],
		\hh: [\dur, 0.1, \emp, 0, \xang, Pwhite(-pi, pi, inf), 
			\yang, Pwhite(-pi, pi, inf), \zang, Pwhite(-pi, pi, inf)
		],
		\ii: [\dur, 0.3, \emp, 0.05, \xang, Pwhite(-pi, pi, inf), 
			\yang, Pwhite(-pi, pi, inf), \zang, Pwhite(-pi, pi, inf)
		],
				
		\xx: [\dur, Pbrown(1/16, 1/8, 1/64, inf), \emp, 0, \xang, Pxrand([0, pi, -0.5pi, 0.5pi], inf), 
			\yang, Pxrand([0, pi, -0.5pi, 0.5pi], inf), \zang, Pxrand([0, pi, -0.5pi, 0.5pi], inf)
		],
		\xy: [\dur, 0.001, \emp, 0, \xang, Pxrand(Array.series(9, -pi, pi/4), inf), 
			\yang, Pxrand(Array.series(9, -pi, pi/4), inf), \zang, Pxrand(Array.series(9, -pi, pi/4), inf)
		],
		\xz: [\dur, Pwhite(0.025, 0.05, inf), \emp, 0, \xang, Pwhite(-pi, pi, inf), 
			\yang, Pwhite(-pi, pi, inf), \zang, Pwhite(-pi, pi, inf)
		],
		\yy: [\dur, Pseq([0.25, 0.125, 0.375, 0.125, 0.25], inf), \emp, 0, 
			\xang, Pseq([-0.25, 0.75, -0.75, 0.25]*pi, inf), \yang, 0, \zang, 0
		],
		\yz: [\dur, Pwhite(0.01, 0.04, inf), \emp, 0, \xang, Pwhite(-pi, pi, inf), 
			\yang, Pwhite(-pi, pi, inf), \zang, Pwhite(-pi, pi, inf)
		],
		\yx: [\dur, Pbrown(1/32, 1/16, 1/64, inf), \emp, Pseq([0.04, 0.02, 0.0, 0.03, 0.01], inf), 
			\xang, Pseq([-0.25, 0, 0.25, 1, -0.75, 0.75]*pi, inf), \yang, 0, \zang, 0
		],
		\zz: [\dur, Pseq(Array.geom(7, 0.1, 1.1).mirror, inf), \emp, 0, \xang, Pwhite(-pi, pi, inf), 
			\yang, Prand([0, pi, -0.5pi, 0.5pi], inf), \zang, Prand([0, pi, -0.5pi, 0.5pi], inf)
		],
		\zx: [\dur, 0.1, \emp, 0, \xang, Pwhite(-pi, pi, inf), 
			\yang, Pwhite(-pi, pi, inf), \zang, Pwhite(-pi, pi, inf)
		],
		\zy: [\dur, 0.3, \emp, 0.05, \xang, Pwhite(-pi, pi, inf), 
			\yang, Pwhite(-pi, pi, inf), \zang, Pwhite(-pi, pi, inf)
		]
		
	).collect({|args, key| 
		Pbind(\instrument, key, \group, ~input.group, \addAction, 0, \out, ~funktBus, \efx, ~funktefxbus, 
			\amp, Pfunc({ ~funktamps[key].amp }), *args).asStream
	});
	
	~funktplay = ~funktpats.collect({|pt,ky| Pdefn(ky,Pseq(pt, inf)).count(128).asStream });
	
	~funktefx01 = Synth.tail(~input.group, \funktrev01, [\out, ~decoder.bus, \in, ~funktefxbus]);

	~funktrout = Routine({
		inf.do({
			~funktplay.keysValuesDo({|name, stream|
				if ((stream.next == 1) and: {~funktamps[name].active > 0}) {
					~funktstreams[name].next(()).play
				}
			});	
			~funktsynths.do({|synth| if (synth.notNil) { synth.run } });
			(~round * rrand(0.99, 1.01)).wait;
		})
	}).play;
	
	// GRAPHICS ****
	
	~graphpats = [2, 3, 5, 6, 7, 10, 11];
	~activepats = Array();
	~flickmap = (
		2: (
			rate: Pseq([1, 2, 1, 1, 2, 4, 1, 2, 1, 4], inf),
			alpha: Pseq([0.5, 1.0, 0.0, 0.5, 1.0], inf)),
		3: (
			rate: Pseq([3, 1, 3, 3], inf), 
			alpha: Pseq([0.6, 0.0, 0.7, 0.0], inf)),
		5: (
			rate: Pseq([2, 4, 1, 2], inf), 
			alpha: Pseq([0.25, 1.0, 0.5, 1.0, 0.25, 0.0, 1.0, 0.75], inf)),
		6: (
			rate: Pseq([2, 4, 2, 4, 2, 1, 1, 1, 1], inf), 
			alpha: Pseq([0.0, 1.0, 0.5, 1.0], inf)),
		7: (
			rate: Pseq([4, 2, 4], inf), 
			alpha: Pseq([0.7, 0.9], inf)),
		10: (
			rate: Pseq([5, 2, 5, 2, 1], inf), 
			alpha: Pseq([0.25, 0.5, 1.0, 0.5, 0.25, 0.5], inf)),
		11: (
			rate: Pseq([2, 1, 1, 1, 2, 1, 1], inf), 
			alpha: Pseq([0.5, 1.0, 0.0, 0.25], inf))
	).collect({|strct| strct.collect(_.asStream) });
	
	~glalpha = 0;
	~avgamp = (0 ! 20);
	~graphcount = 0;	
	
	~graphics.putStatesFunction(\funktgraph, {		
		var map, index;
		index = ~graphpats.wrapAt(~graphcount);
		map = ~flickmap[index];
		if (~graphcount%map['rate'].next == 0) {
			~graphics.sendPattern(index, ~graphics.patternLib[index]['active'], map['alpha'].next * ~glalpha);
		};
		~graphcount = ~graphcount + 1;
	});
	
	~analyzer.putEventResponderFunction(\funktgraph, {|time, re, ms|
		if (ms[2] == 2) {
			~avgamp = ~avgamp.shift(1)[0] = ms[3];
			~glalpha = ~avgamp.mean.explin(0.001, 1.0, 0.5, 1.0);
		};
	});	
	
	// GRAPHICS END ****

	~funktampctr = FaderWarp();
	~funktfont = Font("Courier", 10);
	~funktwin = Window("_o_o_o_o 03 o_o_o_o_", Rect(10, 500, 32*20+200,~funktpats.size*20+70))
		.background_(Color.grey(0.1)).alpha_(0.99).front;
	~patchnames.do({|key, i|
		StaticText(~funktwin, Rect(5,i*20+5,20,20))
			.align_(\center)
			.font_(~funktfont)
			.stringColor_(Color.grey(0.7))
			.string_(key.asString);
		~funktpats[key].do({|onoff,j|
			Button(~funktwin, Rect(j*20+30,i*20+5,20,20))
				.font_(~funktfont)
				.states_([["-", Color.grey(0.5), Color.grey(if(j%8==0){0.25}{0.3})],["o", Color.green, Color.grey(0.6)]])
				.value_(onoff)
				.action_({|btn|
					~funktpats[key][j] = btn.value;
					Pdefn(key, Pseq(~funktpats[key], inf));
				})
		});
		Button(~funktwin, Rect(670,i*20+5,30,20))
			.font_(~funktfont)
			.states_([[\off, Color.grey(0.5), Color.grey(0.2)], [\on, Color.green, Color.grey(0.6)]])
			.action_({|btn|
				~funktamps[key].active = btn.value
			});
		SmoothSlider(~funktwin, Rect(705,i*20+5,100,18))
			.font_(~funktfont)
			.string_("0")
			.stringColor_(Color.grey(0.5))
			.action_({|slider|
				~funktamps[key].amp = ~funktampctr.map(slider.value);
				slider.string_(~funktamps[key].amp.round(0.01).asString)
			})
	});
	
	~funktsynths = Array.newClear(18);
	
	~funktNANO.buttons[0][0..17].do({|btn, i|
		btn.action_({|button|
			if (button.value == 1) {
				~funktsynths[i] = Synth.newPaused(\funktplay, [\out, ~funktBus, \buf, ~funktbufs[i], 
					\rate,  ~funktbufs[i].duration/~funktbufs[i].duration.round(~beatdur)
				], ~input.group, \addToHead)
			}
			{
				~funktsynths[i].free;
				~funktsynths[i] = nil;
			}
		})
	});
	
	~funktNANO.knobs[0].do({|knob, i|
		knob.action_({|kn|
			if (~funktsynths[i].notNil) {
				~funktsynths[i].set(\amp, ~funktampctr.map(kn.value))
			}
		})
	});
	
	~funktNANO.sliders[0].do({|slider, i|
		slider.action_({|sl|
			if (~funktsynths[i + 9].notNil) {
				~funktsynths[i + 9].set(\amp, ~funktampctr.map(sl.value))
			}
		})
	});
		
}).play(AppClock);