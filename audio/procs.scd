(
	bufs: {
		var events;
		events = ~mikro.analyzer.selectEvents(0.1, 6.0).reverse.keep(rrand(3, 5)).reverse;
		if (events.size > 0) {
			Routine({
				rrand(2, 4).do({
					events.do({|ev|
						var def, id;
						def = \bufplay;
						id = ~composer.play(def, Env([0.001, 1.0, 1.0, 0.001], [0.2, 0.6, 0.2], \sine), 
							Pseq(~graphics.bmu.vector ? ~graphics.states, inf).asStream, ev.buffer, 
							ev.duration
						);
						ev.duration.wait;
					});
				})
			}).play		
		}
		{
			~mikro.gui.post("0 events for bufrecent");
		}
	},
	bufr: {
		var events, ind, end;
		events = ~mikro.analyzer.selectEvents(0.1, 6.0);
		if (events.size > 10) {
			ind = events.size.rand;
			end = min(ind + rrand(3, 6), events.size - 1);
			events = events[ind..end];
			Routine({
				events.do({|ev|
					var def, id;
					def = \bufplay;
					id = ~composer.play(def, Env([0.001, 1.0, 1.0, 0.001], [0.2, 0.6, 0.2], \sine), 
						Pseq(~graphics.bmu.vector ? ~graphics.states, inf).asStream, ev.buffer, 
						ev.duration
					);
					ev.duration.wait;
				})
			}).play		
		}
		{
			~mikro.gui.post("0 events for bufrand");
		}
	},
	tyhi: {

		var events, dur;
		events = ~mikro.analyzer.selectEvents(0.1, 5.0).scramble.keep(8);
		dur = rrand(6, 10);
		if (events.size == 8 ) {
			events.do({|ev|
				var def, id;
				def = \tyhi;
				id = ~composer.play(def, Env([0.001, 1.0, 1.0, 0.001], [0.3, 0.4, 0.3], \sine), 
					Pseq(~graphics.bmu.vector ? ~graphics.states, inf).asStream, ev.buffer, 
					dur
				);
			})
		}
		{
			~mikro.gui.post("0 events for tyhi");
		}
			
	},
	rwrp: {
		
		var events, dur;
		events = ~mikro.analyzer.selectEvents(0.1, 5.0).scramble.keep(6);
		dur = rrand(5, 10);
		if (events.size == 6) {
			events.do({|ev|
				var def, id;
				def = \rwarp;
				id = ~composer.play(def, Env([0.001, 1.0, 1.0, 0.001], [0.3, 0.4, 0.3], \sine), 
					Pseq(~graphics.bmu.vector ? ~graphics.states, inf).asStream, ev.buffer, 
					ev.duration * 3
				);
			})
		}
		{
			~mikro.gui.post("0 events for tyhi");
		}
		
	}
);