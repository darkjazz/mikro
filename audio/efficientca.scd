n = 40;
a = Array.fill(n, { Array.fill(n, { (states: (0 ! 3)) }) });
h = ([(0..2).stutter(3), ((0..2) ! 3).flat].lace(18) - 1).clump(2);
h.removeAt(4);

~next = {|cell, index, x, y, add|	
// index points to state used in calculation, new state put to wrap(index + 1)
	var avg = 0;
	h.do({|rel|
		avg = avg + a.wrapAt(x + rel[0]).wrapAt(y + rel[1]).states[index];
	});
	avg = avg / 8 + add;
	cell.states[(index+1).wrap(0,2)] = avg.wrap(0.0, 1.0);
	
};

z = 10;
i = 0;
d = 0.996;
w = Window("oo-oo-oooooooo-oo------o", Rect(200, 200, z * n + 10 * 1.33, z * n + 10)).front;
w.drawHook = {
	a.do({|row, x|
		row.do({|cell, y|
			Pen.color = Color.grey(cell.states[i]);
			Pen.fillRect(Rect(x*z+5*1.33, y*z+5, z*1.33, z));
			~next.value(a[x][y], i, x, y, d);
		})
	});
	i = (i+1).wrap(0,2);
}

r=Routine({
	inf.do({ 
		a.choose.choose.states[i] = 1.0;
		{w.refresh}.defer; 
		0.1.wait 
	})
}).play


r.stop

80**2