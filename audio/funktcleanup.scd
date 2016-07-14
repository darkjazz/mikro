~funktrout.stop;
~funktrout = nil;
~funktfuncs.clear;
~funktfuncs = nil;
~funktenvs.clear;
~funktenvs = nil;
~funktefx01.free;
~funktefx = nil;
~funktefxbus.free;
~funktefxbus = nil;
~funktpats.clear;
~funktpats = nil;
~funktamps.clear;
~funktamps = nil;
~funktstreams.clear;
~funktstreams = nil;
~funktplay.clear;
~funktplay = nil;
~funktsynths = nil;
~funktNANO.buttons[0][0..17].do({|btn, i| btn.action_({}) });
~funktNANO.knobs[0].do({|knob, i| knob.action_({}) });
~funktNANO.sliders[0].do({|slider, i| slider.action_({}) });

~funktwin.close;
~funktwin = nil;

~graphics.removeStatesFunction(\funktgraph);
~analyzer.removeEventResponderFunction(\funktgraph);