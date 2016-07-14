//~graphics = MikroGraphics(800, 600, 33, 25, 36, NetAddr("127.0.0.1", 7770), 12, 5000, 0.1);
//~graphics.start;
//~graphics.quit

(

r=Routine({
	~graphpats = [2, 3, 5, 6, 7, 10, 11];
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
	inf.do({|i|
		~graphpats.do({|index|
			var map, alpha;
			map = ~flickmap[index];
			if (i%map['rate'].next == 0) {
				alpha = map['alpha'].next;
				~graphics.sendPattern(index, ~graphics.patternLib[index]['active'], alpha);
				0.05.wait;
			}
		});
		0.05.wait;
	})
//	~analyzer.addEventResponderFunction(\grph, {|time, re, ms|
//		if (ms[2] == 2) {
//			~avgamp = ~avgamp.shift(1)[0] = ms[3];
//			~glalpha = ~avgamp.mean;
//		}
//	});
	
}).play;

)


r.stop