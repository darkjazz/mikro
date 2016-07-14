(
	proc00: {|composer, analyzer|
		var srcA, srcB, current, def;
		def = composer.descLib[\bufplay];
		#srcB, srcA = analyzer.events.reverse.keep(2);
		
		current = (
			xenv: composer.envSet[srcB.duration.round(composer.timeQuant)],
			xdur: srcB.duration.round(composer.timeQuant).clip(0.0625, 4.0),
			xfrq: composer.roundFreq(srcA.meanFreq) / composer.roundFreq(srcB.meanFreq),
			xamp: srcB.peakAmp.round(composer.roundAmp),
			xtime: abs(srcB.start - srcA.start).round(composer.timeQuant).clip(0.0625, 4.0),
		);
				
		Tdef(\proc00, {
			rrand(4, 16).round(4).do({
				var params, stream;
				stream = Pbrown(0.0, 1.0, 1/11, inf).asStream;
				params = [\out, ~mikro.decoder.bus, \in, ~mikro.input.bus, \dur, current.xdur ? 0.5, 
					\buf, srcB.buffer, \rate, current.xfrq ? 1.0, \amp, current.xamp ? 1.0 ] 
					++ def.metadata.specs.collect(_.map(stream.next)).asKeyValuePairs;
				Synth.tail(~mikro.group, def.name, params).setn(\env, current.xenv);
				(current.xtime ? 0.25).wait;
				current = (
					xenv: composer.envSet[current.xdur],
					xdur: (composer.durChain.next(current.xdur) ? 0.5).clip(0.0625, 4.0),
					xfrq: composer.intChain.next(current.xfrq),
					xamp: composer.ampChain.next(current.xamp),
					xtime: (composer.timeChain.next(current.xtime) ? 0.5).clip(0.0625, 4.0)
				);
			});
			Tdef(\proc00).clear;
		});
		Tdef(\proc00).play;
		
	},

	proc01: {|composer, analyzer|
		var srcA, srcB, current, def;
		def = composer.descLib[\bufplay];
		srcB = analyzer.events.drop(1).choose;
		srcA = analyzer.events[analyzer.events.indexOf(srcB) - 1];
		
		current = (
			xenv: composer.envSet[srcB.duration.round(composer.timeQuant)],
			xdur: srcB.duration.round(composer.timeQuant).clip(0.0625, 4.0),
			xfrq: composer.roundFreq(srcA.meanFreq) / composer.roundFreq(srcB.meanFreq),
			xamp: srcB.peakAmp.round(composer.roundAmp),
			xtime: abs(srcB.start - srcA.start).round(composer.timeQuant).clip(0.0625, 4.0),
		);
				
		Tdef(\proc01, {
			rrand(4, 12).round(4).do({
				var params, stream;
				stream = Pbrown(0.0, 1.0, 1/11, inf).asStream;
				params = [\out, ~mikro.decoder.bus, \in, ~mikro.input.bus, \dur, current.xdur ? 0.5, 
					\buf, srcB.buffer, \rate, current.xfrq ? 1.0, \amp, current.xamp ? 1.0 ] 
					++ def.metadata.specs.collect(_.map(stream.next)).asKeyValuePairs;
				Synth.tail(~mikro.group, def.name, params).setn(\env, current.xenv);
				(current.xtime ? 0.25).wait;
				current = (
					xenv: composer.envSet[current.xdur],
					xdur: (composer.durChain.next(current.xdur) ? 0.5).clip(0.0625, 4.0),
					xfrq: composer.intChain.next(current.xfrq),
					xamp: composer.ampChain.next(current.xamp),
					xtime: (composer.timeChain.next(current.xtime) ? 0.5).clip(0.0625, 4.0)
				);
			});
			Tdef(\proc01).clear;
		});
		Tdef(\proc01).play;
		
	},

	proc02: {|composer, analyzer|
		var srcA, srcB, current, def;
		def = composer.descLib[\bufplay];
		srcB = analyzer.events.drop(1).wchoose((analyzer.events.size..2).normalizeSum);
		srcA = analyzer.events[analyzer.events.indexOf(srcB) - 1];
		
		current = (
			xenv: composer.envSet[srcB.duration.round(composer.timeQuant)],
			xdur: srcB.duration.round(composer.timeQuant).clip(0.0625, 8.0),
			xfrq: composer.roundFreq(srcA.meanFreq) / composer.roundFreq(srcB.meanFreq),
			xamp: srcB.peakAmp.round(composer.roundAmp),
			xtime: abs(srcB.start - srcA.start).round(composer.timeQuant).clip(0.0625, 4.0),
		);
				
		Tdef(\proc02, {
			rrand(4, 12).round(4).do({
				var params, stream;
				stream = Pbrown(0.0, 1.0, 1/11, inf).asStream;
				params = [\out, ~mikro.decoder.bus, \in, ~mikro.input.bus, \dur, current.xdur ? 0.5, 
					\buf, srcB.buffer, \rate, current.xfrq ? 1.0, \amp, current.xamp ? 1.0 ] 
					++ def.metadata.specs.collect(_.map(stream.next)).asKeyValuePairs;
				Synth.tail(~mikro.group, def.name, params).setn(\env, current.xenv);
				(current.xtime ? 0.25).wait;
				current = (
					xenv: composer.envSet[current.xdur],
					xdur: (composer.durChain.next(current.xdur) ? 0.5).clip(0.0625, 8.0),
					xfrq: composer.intChain.next(current.xfrq),
					xamp: composer.ampChain.next(current.xamp),
					xtime: (composer.timeChain.next(current.xtime) ? 0.5).clip(0.0625, 4.0)
				);
			});
			Tdef(\proc02).clear;
		});
		Tdef(\proc02).play;
		
	},

	proc03: {|composer, analyzer|
		var srcA, srcB, current, def;
		def = composer.descLib[\rwarp];
		#srcB, srcA = analyzer.events.reverse.keep(2);
		
		current = (
			xenv: composer.envSet[srcA.duration.round(composer.timeQuant)],
			xdur: srcA.duration.round(composer.timeQuant).clip(0.0625, 8.0),
			xfrq: composer.roundFreq(srcB.meanFreq) / composer.roundFreq(srcA.meanFreq),
			xamp: srcA.peakAmp.round(composer.roundAmp),
			xtime: (srcB.start - srcA.start).round(composer.timeQuant).clip(0.0625, 4.0),
		);
				
		Tdef(\proc03, {
			rrand(4, 12).round(4).do({
				var params, stream;
				stream = Pbrown(0.0, 1.0, 1/11, inf).asStream;
				params = [\out, ~mikro.decoder.bus, \in, ~mikro.input.bus, \dur, current.xdur ? 0.5, 
					\buf, [srcB, srcA].choose.buffer, \frq, current.xfrq ? 1.0, \amp, current.xamp ? 1.0 ] 
					++ def.metadata.specs.collect(_.map(stream.next)).asKeyValuePairs;
				Synth.tail(~mikro.group, def.name, params).setn(\env, current.xenv);
				(current.xtime ? 0.25).wait;
				current = (
					xenv: composer.envSet[current.xdur],
					xdur: (composer.durChain.next(current.xdur) ? 0.5).clip(0.0625, 8.0),
					xfrq: composer.intChain.next(current.xfrq),
					xamp: composer.ampChain.next(current.xamp),
					xtime: (composer.timeChain.next(current.xtime) ? 0.5).clip(0.0625, 4.0)
				);
			});
			Tdef(\proc03).clear;
		});
		Tdef(\proc03).play;
		
	}	
)
