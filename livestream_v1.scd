/*

Mixdown Mic plus SC to (eventually) BlackHole

*/

// s.options.outDevice_("BlackHole 16ch"); // or s.options.outDevice_("UltraLite mk3 Hybrid");

s.options.inDevice_("UltraLite mk3 Hybrid");
s.options.outDevice_("UltraLite mk3 Hybrid"); // or s.options.outDevice_("BlackHole 16ch");
s.options.memSize = 2097152;

s.boot;


// mic in to stereo

SynthDef( \in, { | amp = 0.0, attack = 0.01, freq = 333, release = 1, trig = 0 |
    var env, sig;

    env = Env.asr( attack, 0.9, release ).kr( Done.freeSelf, trig );
    sig = SoundIn.ar( 0, amp );
    Out.ar( 0, Pan2.ar( env * sig ) );
    Out.ar( b,
}).add;



// pre-mixer

SynthDef( \masterOut, { | private, source1, source2, micAmp = 0.5, scAmp = 0.5, out = 0, pan = 0, trig = 0 |
	var env, finalsig, s1, s2, s3, sig;

    env = Env.asr( attack, 0.9, release ).kr( Done.freeSelf, trig );
	s1 = In.ar( source1, 1 ) * micAmp;
    s2 = In.ar( source2, 1 ) * scAmp;
	sig = Mix.new( [ s1, s2 ] );
	finalsig = sig * env;
	Out.ar( out, Pan2.ar( finalsig, pan ) );
}).add;


// run the synths

x = Synth.new( \in, [ \amp, 0.9, \trig, 1 ]);