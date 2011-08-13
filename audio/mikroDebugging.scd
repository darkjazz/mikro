m = MikroGraphics(800, 600, 40, 40, 30, NetAddr("127.0.0.1", 7770), 8, 5000, 0.1);

m.putBmuFunction(\test, {|bmu|
	bmu.postln
})

m

m.removeBmuFunction(\test)

m.start

m.sendPattern(9, 1, 0)

(
Routine({
	
	1000.do({
		var arr = Array.rand(8, 0.0, 1.0);
		m.sendWeights(*arr);
		0.1.wait;
	});
	
	"finished".postln
	
}).play
)

m.sendSetting(\add, 0.01)

m.bmu.x
m.sendWeights(*Array.rand(8, 0.0, 1.0))

r = OSCresponderNode(nil, '/mikro/bmu', {|ti, re, ms|
	
	ms.asFloatArray
}).add

r.remove

m.sendMsg("settings", 0.05)

m.bmu.x

m.quit

x = Array()

r.sendMsg("/mikro/bg", 0.2, 0.5, 0.4)

r.sendMsg("/mikro/quit", 0)

r.sendMsg("/mikro/settings", 0.004)

a =  Array.rand(8, 0.0, 1.0)
r.sendMsg("/mikro/weights", *a);

Fx3D

Routine({
	
	1000.do({
		var arr = Array.rand(8, 0.0, 1.0);
		r.sendMsg("/mikro/weights", *arr);
		0.1.wait;
	});
	
	"finished".postln
	
}).play


