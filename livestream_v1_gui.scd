// GUI for Mixdown Mic plus SC to Ultralite


(
// setup gui
~window = Window.new("mixer", Rect(0, 0, 400, 305));

~window.background = Color.gray(0.15);

// how do i compute these coordinates per x num sources?
~col = [10, 120, 230, 340 ];
~row1 = [ 10, 10, 10, 10, 10 ];
~row2 = [60, 60, 60, 60 ];
~row3 = [120, 120, 120, 120];


// MIXER
// setup gui elements (label, number box (exact val), knob (approx val)) per source
for(0, ~sources.size - 1, { | i |

	// label
	a[("k"++i++"Label").asSymbol] = StaticText(~window, Rect( ~col[i], ~row1[i], 100, 50));
	a[("k"++i++"Label").asSymbol].align = \center;
	a[("k"++i++"Label").asSymbol].background = Color.gray(0.15);
	a[("k"++i++"Label").asSymbol].stringColor = Color.white;
	a[("k"++i++"Label").asSymbol].string = ~sources[i].asString;


	// display val in NumberBox
	a[("k"++i++"Val").asSymbol] = NumberBox(~window, Rect(~col[i], ~row2[i], 100, 50));
	a[("k"++i++"Val").asSymbol].align = \center;
	a[("k"++i++"Val").asSymbol].background = Color.white;


	// make the knob, connect to NumberBox
	a[("k"++i).asSymbol] = Knob.new(~window, Rect(~col[i], ~row3[i], 100, 100));
	a[("k"++i).asSymbol].background_(Color.black);
	a[("k"++i).asSymbol].action_{ |knob|
		a[((~sources[i])++"BusVol").asSymbol].set(knob.value); // gui updates bus
		a[("k"++i++"Val").asSymbol].value_(knob.value); // gui updates numberbox
	};

});

~run = False; // flag to denote masterout is running

// master output toggle
~runMaster = Button(~window, Rect( 10, 240, 100, 25 ) )
.canFocus_(false)
.states_([
	["OFF", Color.black, Color.gray],
	["ON", Color.black, Color.red]
])
.action_({ arg butt;

	if( butt.value == 1, {
		if( ~run == False, {
			"RUN MASTER OUT".postln;
			~m = Synth.new(\masterOut, [ \source1, ~micBus.index, \source2, ~workshopSynthsBus.index, \micAmp, ~micBusVol.asMap, \workshopSynthsAmp, ~workshopSynthsBusVol.asMap, \trig, 1], ~finalMix);
			~run = True;
            ~x = Synth.new( \mic, [ \amp, 0.9, \trig, 1, \outBus, ~micBus.index ], ~mic );
		});
		},{
        "STOP MASTER OUT".postln;
        ~m.set(\trig, 0);
        ~m.free;
        ~x.free;
        ~run = False;
	});
});

~window.front;

// twister to gui (replace this with quark for twister)

// connect midi controller to gui per each source, enables mixing

for(0, ~sources.size - 1, { | i |

	MIDIFunc.cc({arg ...msg;
		var val = msg[0].linlin(0, 127, 0.0, 1.0);
		{ a[("k"++i).asSymbol].valueAction_(val) }.defer;
	}, i, srcID: ~twisterPort.uid);
});


)