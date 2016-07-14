~graphics = MikroGraphics(800, 600, 33, 25, 36, NetAddr("127.0.0.1", 7770), 8, 5000, 0.1);


(
var window, graphwin, graphSliders, font, btns, rtn, addspec, xspec, yspec, zspec, xstr, ystr, debug = 1;

font = Font("Inconsolata", 10);
btns = Array.newClear(~graphics.numPatterns);
addspec = CosineWarp(ControlSpec(0.001, 0.999));

xspec = ControlSpec(-80, 0);
yspec = ControlSpec(-60, 0);
zspec = ControlSpec(0, 80);

window = Window("-----...-----", Rect(100, 100, 620, 500)).alpha_(0.98).background_(Color.grey(0.15)).front;
graphwin = CompositeView(window, Rect(5, 5, 590, 120));

graphwin.decorator = FlowLayout(graphwin.bounds, 5@5, 5@5);
		
graphSliders = Array.newClear(~graphics.numPatterns);

~graphics.settings[\bgred] = 0.0;
~graphics.settings[\bggreen] = 0.0;
~graphics.settings[\bgblue] = 0.0;
~graphics.settings[\groupx] = 5;
~graphics.settings[\groupy] = 5;
~graphics.settings[\transz] = 40;
~graphics.settings[\transx] = -40;
~graphics.settings[\transy] = -30;

~graphics.numPatterns.do({|i|
	btns[i] = RoundButton(graphwin, Rect(width: graphwin.bounds.width / ~graphics.numPatterns - 6, height: 20))
		.font_(font)
		.states_([
			[i.asStringToBase(10, 2), Color.yellow, Color.black], 
			[i.asStringToBase(10, 2), Color.black, Color.yellow]
		])
		.action_({|btn|
			if (btn.value == 1)
			{
				~graphics.sendPattern(i, 1, 0.0);
			}
			{
				~graphics.sendPattern(i, 0, 0.0);
			}
		});
		
});

~graphics.numPatterns.do({|i|

	graphSliders.put(i, SmoothSlider(graphwin, 
		Rect(width: graphwin.bounds.width / ~graphics.numPatterns - 6, height: 150))
			.action_({|slider|
				~graphics.sendPattern(i, btns[i].value, slider.value)
			})
	)
	
});

RoundButton(window, Rect(5, 200, 60, 25))
	.font_(font)
	.states_([[".debug.", Color.grey(0.8), Color.grey(0.3)], ["!live!", Color.yellow, Color.grey(0.5)]])
	.action_({|btn|
		if (btn.value == 1) { debug = 2 	} { debug = 1 }
	});
	
RoundButton(window, Rect(70, 200, 60, 25))
	.font_(font)
	.states_([[".ogl.", Color.grey(0.8), Color.grey(0.3)], ["..g..", Color.green, Color.grey(0.5)]])
	.action_({|btn|
		if (btn.value == 1) {
			~graphics.start(debug)
		}{
			~graphics.quit;
			if (rtn.notNil) { rtn.stop; rtn.clear; rtn = nil; }
		}
	});
	
RoundButton(window, Rect(135, 200, 60, 25))
	.font_(font)
	.states_([[".data.", Color.grey(0.8), Color.grey(0.3)], ["..at..", Color.green, Color.grey(0.5)]])
	.action_({|btn|
		if (btn.value == 1) {
			rtn = Routine({
				inf.do({
					~graphics.sendWeights(*Array.rand(~graphics.vectorSize, 0.0, 1.0));
					0.1.wait;
				})
			}).play
		}{
			rtn.stop;
			rtn = nil;
		}		
	});
	
SmoothSlider(window, Rect(200, 200, 120, 25))
	.stringColor_(Color.green)
	.string_("0.995")
	.hilightColor_(Color.clear)
	.value_(addspec.unmap(0.995))
	.action_({|sl|
		~graphics.sendSetting(\add, addspec.map(sl.value));
		sl.string_(addspec.map(sl.value).round(0.001).asString)
	});		

Slider2D(window, Rect(5, 240, 200, 200))
	.x_(0.5)
	.y_(0.5)
	.action_({|slider|
		~graphics.settings[\transx] = xspec.map(slider.x);
		~graphics.settings[\transy] = yspec.map(slider.y);
		~graphics.sendSettings;
		xstr.string_("x: " ++ ~graphics.settings[\transx].round(1).asString);
		ystr.string_("y: " ++ ~graphics.settings[\transy].round(1).asString);
	});
	
xstr = StaticText(window, Rect(5, 240, 200, 15))
	.font_(font)
	.stringColor_(Color.grey(0.7))
	.align_(\center)
	.string_("x: -40");

ystr = StaticText(window, Rect(165, 330, 40, 25))
	.font_(font)
	.stringColor_(Color.grey(0.7))
	.align_(\center)
	.string_("y: -30");

SmoothSlider(window, Rect(215, 240, 30, 200))
	.background_(Color.clear)
	.border_(1)
	.hilightColor_(Color.clear)
	.stringColor_(Color.green)
	.string_(~graphics.settings[\transz].asString)
	.value_(0.5)
	.action_({|slider|
		~graphics.sendSetting(\transz, zspec.map(slider.value));
		slider.string_(zspec.map(slider.value).round(1).asString)
	});

SmoothSlider(window, Rect(260, 240, 30, 200))
	.background_(Color.clear)
	.border_(1)
	.hilightColor_(Color.clear)
	.stringColor_(Color.green)
	.string_(~graphics.settings[\bgred].asString)
	.value_(0.0)
	.action_({|slider|
		~graphics.sendSetting(\bgred, slider.value);
		slider.string_(slider.value.round(0.01).asString)
	});

SmoothSlider(window, Rect(295, 240, 30, 200))
	.background_(Color.clear)
	.border_(1)
	.hilightColor_(Color.clear)
	.stringColor_(Color.green)
	.string_(~graphics.settings[\bggreen].asString)
	.value_(0.0)
	.action_({|slider|
		~graphics.sendSetting(\bggreen, slider.value);
		slider.string_(slider.value.round(0.01).asString)
	});

SmoothSlider(window, Rect(330, 240, 30, 200))
	.background_(Color.clear)
	.border_(1)
	.hilightColor_(Color.clear)
	.stringColor_(Color.green)
	.string_(~graphics.settings[\bgblue].asString)
	.value_(0.0)
	.action_({|slider|
		~graphics.sendSetting(\bgblue, slider.value);
		slider.string_(slider.value.round(0.01).asString)
	});
	
)


[0, 1]