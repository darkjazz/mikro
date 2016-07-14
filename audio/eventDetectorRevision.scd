(
SynthDef(\play, {|out, buf|
	var sig;
	sig = PlayBuf.ar(1, buf, doneAction: 2);
	Out.ar(out, sig);
	Out.ar(0, sig.dup)
}).add;

SynthDef(\eventDetector, {|krout, in, onsetth, offth, lag, msgrate|
	var input, onsets, chain, isOn, amp, off, local, mfcc, event, flat, pch;
	input = In.ar(in);
	amp = Amplitude.kr(input, lag);
	pch = Pitch.kr(input).at(0);
	chain = FFT(LocalBuf(1024), input);
	onsets = Onsets.kr(chain, onsetth);
	mfcc = MFCC.kr(chain, 12);
	flat = SpecFlatness.kr(chain);
	event = Impulse.kr(msgrate);
	off = LagUD.kr(Trig.kr(amp < offth, lag), 0.01, 0.02);
	SendReply.kr(onsets, '/event', onsets, 1);
	SendReply.kr(off, '/event', 0, 0);
	SendReply.kr(event, '/event', amp, 2);
	SendReply.kr(event, '/event', mfcc, 3);
	SendReply.kr(event, '/event', flat, 4);
	SendReply.kr(event, '/event', pch, 5);	
}).add;

b = Buffer.read(s, "/Users/alo/sounds/christian/monoclipmx.aif");

~isOn = false;

~events = Array();

~addEvent = {|ti|
	~currentEvent[\duration] = ti - ~currentEvent[\start];
	~events = ~events.add(~currentEvent);
	Post << "added event with duration " << ~currentEvent[\duration] << Char.nl;
	~currentEvent = nil;
};
)

(
~bus = Bus.audio;
~input = Synth(\play, [\out, ~bus, \buf, b]);
~analyzer = Synth.after(~input, \eventDetector, [\in, ~bus, \onsetth, -3.dbamp, \offth, -20.dbamp, \lag, 0.1, \msgrate, 30]);

~resp = OSCresponderNode(s.addr, '/event', {|ti, re, ms|
	
	if (ms[2] == 1) {
		Post << "ONSET" << Char.nl;
		~isOn = true;
		if (~currentEvent.notNil) {
			 ~addEvent.value(ti);
		};
		~currentEvent = (start: ti, duration: 0)
	};
	if (ms[2] == 0) {
		Post << "OFF" << Char.nl;
		~isOn = false;
		if (~currentEvent.notNil) { ~addEvent.value(ti) };
	}	
}).add

)

(
~resp.remove;
~input.free;
~analyzer.free
)