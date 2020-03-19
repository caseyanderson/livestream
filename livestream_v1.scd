/*

Mixdown Mic plus SC to Ultralite

*/

// s.options.outDevice_("BlackHole 16ch"); // or s.options.outDevice_("UltraLite mk3 Hybrid");

s.options.inDevice_("UltraLite mk3 Hybrid");
s.options.outDevice_("BlackHole 16ch"); // or s.options.outDevice_("BlackHole 16ch");
s.options.memSize = 2097152;

s.boot;

~twisterPort = MIDIIn.findPort("Midi Fighter Twister", "Midi Fighter Twister");
MIDIIn.connectAll;

(
///////// setup and routing
// make environment
a = currentEnvironment;

// list of sources
~sources = Array.with('mic', 'workshopSynths');

// 1 group per source + finalMix group
~mic = Group.new;
~workshopSynths = Group.after(~mic);
~finalMix = Group.after(~workshopSynths);


// make the audio and control busses for each sources
for( 0, (~sources.size - 1), { | i |
	a[((~sources[i])++"Bus").asSymbol] = Bus.audio(s, 1);
	a[((~sources[i])++"BusVol").asSymbol] = Bus.control(s, 1).set(0.0);
});

)


// mic in to stereo
(
SynthDef( \mic, { | outBus, amp = 0.0, attack = 0.01, freq = 333, release = 1, trig = 0 |
    var env, sig;

    env = Env.asr( attack, 0.9, release ).kr( Done.freeSelf, trig );
    sig = SoundIn.ar( 0, amp );
    //Out.ar( 0, env * sig );
    Out.ar( outBus, sig * env );
}).add;

SynthDef( \sin, { | outBus, amp = 0.0, attack = 0.01, freq = 333, release = 1, sus = 2, trig = 0 |
    var env, sig;

    env = Env.linen( attack, sus, release ).kr( Done.freeSelf, trig );
    sig = SinOsc.ar([ freq, freq * 0.999 ], 0.0, amp );
	//Out.ar( 0, env * sig  );
    Out.ar( outBus, sig * env * 0.4 );
}).add;

~dur = { exprand( 0.5, 6.0 )};

// pre-mixer

SynthDef( \masterOut, { | attack = 0.1, release = 1.0, source1, source2, micAmp = 0.5, workshopSynthsAmp = 0.5, out = 0, pan = 0, trig = 0 |
    var env, finalsig, s1, s2, sig;

    env = Env.asr( attack, 0.9, release ).kr( Done.freeSelf, trig );
    s1 = In.ar( source1, 1 ) * micAmp;
    s2 = In.ar( source2, 1 ) * workshopSynthsAmp;
    sig = Mix.new( [ s1, s2 ] );
    finalsig = sig * env;
    Out.ar( out, Pan2.ar( finalsig, pan ) );
}).add;

OSCFunc( { | msg |
		var dur, freq, fund = 200;
        // msg.postln;

		freq = msg[1] * fund;
		dur = ~dur.value;
		( "freq is" + freq + "dur is" + dur ).postln;
/*		Synth.new( \sin, [ \amp, 0.6, \freq, freq, \sus, dur, \trig, 1 ] );*/
    Synth.new( \sin, [ \amp, 0.6, \freq, freq, \sus, dur, \trig, 1, \outBus, ~workshopSynthsBus.index ], ~workshopSynths );

	}, "/engine" );
)


// one shot
Synth.new( \sin, [ \amp, 0.6, \freq, 200, \sus, ~dur.value, \trig, 1, \outBus, ~workshopSynthsBus.index ], ~workshopSynths );
