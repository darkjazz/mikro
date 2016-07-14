RSdecoder{
	
	var bus, target, synth, server, speakers;
	var scopeInBuf, scopeOutBuf;
	
	*new{|bus, target|
		^super.newCopyArgs(bus, target).init
	}
	
	init{
		var spec;
		{
			
			spec = [
				[0.125, 0.2],
				[0.375, 0.2],
				[0.625, 0.2],
				[0.875, 0.2],
				[-0.875, 0.2],
				[-0.625, 0.2],
				[-0.375, 0.2],
				[-0.125, 0.2],

				[0.125, -0.2],
				[0.375, -0.2],
				[0.625, -0.2],
				[0.875, -0.2],
				[-0.875, -0.2],
				[-0.625, -0.2],
				[-0.375, -0.2],
				[-0.125, -0.2]
				
			];
		
			speakers = (
				\azimuth: spec.flop[0] * pi,
				\elevation: spec.flop[1] * pi
			);
			
			server = Server.default;
			
			server.sync;
			
			synth = SynthDef(\rsdecoder, {|iamp = 1.0|
				var w, x, y, z;
				#w, x, y, z = In.ar(bus.index, 4) * iamp;
				Out.ar(0, BFDecode1.ar(w, x, y, z, speakers.azimuth, speakers.elevation))
			}).play(target, addAction: \addAfter);
		
			server.sync;
			
			scopeInBuf = Buffer.alloc(server, 4096, 4);
			scopeOutBuf = Buffer.alloc(server, 4096, 16);
			
			server.sync;
			
			SynthDef(\scopeInput, {
				ScopeOut.ar(In.ar(bus.index, 4), scopeInBuf.bufnum)
			}).play(target, addAction: \addAfter);
		
			SynthDef(\scopeOutput, {
				ScopeOut.ar(In.ar(0, 16), scopeOutBuf.bufnum)
			}).play(synth, addAction: \addAfter);
			
			server.sync;
			
			{this.scope}.defer
		
		}.fork;
		
				
		
	}
	
	scope{
	
		var win, wout;
		
		win = SCWindow("._. b-format ._.", Rect(10, 500, 400, 200)).front;
		win.view.background = HiliteGradient(Color.black, Color.grey(0.3), \v, 512, 0.5);
		SCScope(win, Rect(10, 10, 380, 180))
			.bufnum_(scopeInBuf.bufnum)
			.background_(Color.grey(0.3, 0.3))
			.waveColors_(({Color.green} ! 4))
			.yZoom_(5);
		
		wout = SCWindow("._. output ._.", Rect(420, 500, 400, 800)).front;
		wout.view.background = HiliteGradient(Color.black, Color.grey(0.3), \v, 512, 0.5);
		SCScope(wout, Rect(10, 10, 380, 780))
			.bufnum_(scopeOutBuf.bufnum)
			.background_(Color.grey(0.3, 0.3))
			.waveColors_(({Color.green} ! 16))
			.yZoom_(5);
	
	}
	
}