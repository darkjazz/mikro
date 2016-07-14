(
~localDecoder = false;

SynthDef(\mikroBACKUP, {|out, aux, xamp, gamp, xang, yang, zang, maxdel|
	var input, del, shift, w, x, y, z;
	del = Array.geom(4, 0.01, 1.618);
	shift = Array.geom(4, 36/35, 35/36);
	input = SoundIn.ar(0);
	Out.ar(aux, input * xamp);
	#w, x, y, z = A2B.ar(*Array.fill(4, {|i|
		PitchShift.ar(DelayN.ar(input, maxdel, del[i]), 0.2, shift[i])
	}));
	#w, x, y, z = AtkRotateXYZ.ar(w, x, y, z, xang, yang, zang) * gamp;
	if (~localDecoder) {
		Out.ar(out, BFDecode1.ar(w, x, y, z, [-0.25, -0.75, 0.75, 0.25] * pi, (0 ! 4)))
	}
	{
		Out.ar(out, Array.with(w, x, y, z))
	}
}).add;

)

(
~aux = Bus.audio;
~respStart = OSCresponderNode(nil, '/mikro/backup', {|ti, re, ms|
	if (ms[1] == 1)
	{
	~synth = Synth(\mikroBACKUP, [\out, 0, \aux, ~aux, \xamp, 0, \gamp, 0, 
		\xang, 0, \yang, 0, \zang, 0, \maxdel, 0.4])
	};
	if (ms[1] == 2)
	{
	~synth.free	
	}
}).add;

)

