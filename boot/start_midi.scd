(
var on, off, cc;
var osc_tidal, osc_nvim;

MIDIClient.init;
MIDIIn.connectAll;

if(~tidal_midi_in) { osc_tidal = NetAddr.new("127.0.0.1", 6010); };
if(~nvim_midi_in) { osc_nvim = NetAddr.new("127.0.0.1", 9000); };

if(~tidal_midi_in && ~nvim_midi_in) {
    on = MIDIFunc.noteOn({ |val, num, chan, src|
        if(chan == 0) {
            osc_nvim.sendMsg("/note", num.asString, val);
        } {
            osc_tidal.sendMsg("/ctrl", num.asString, val / 127);
        };
    });

    off = MIDIFunc.noteOff({ |val, num, chan, src|
        if(chan != 0) {
            osc_tidal.sendMsg("/ctrl", num.asString, 0);
        };
    });

    cc = MIDIFunc.cc({ |val, num, chan, src|
        osc_tidal.sendMsg("/ctrl", num.asString, val / 127);
    });
};

if(~tidal_midi_in && ~nvim_midi_in.not) {
    on = MIDIFunc.noteOn({ |val, num, chan, src|
        osc_tidal.sendMsg("/ctrl", num.asString, val / 127);
    });

    off = MIDIFunc.noteOff({ |val, num, chan, src|
        osc_tidal.sendMsg("/ctrl", num.asString, 0);
    });

    cc = MIDIFunc.cc({ |val, num, chan, src|
        osc_tidal.sendMsg("/ctrl", num.asString, val / 127);
    });
};

if(~nvim_midi_in && ~tidal_midi_in.not) {
    on = MIDIFunc.noteOn({ |val, num, chan, src|
        if(chan == 0) {
            osc_nvim.sendMsg("/note", num.asString, val);
        };
    });
};

if(~tidal_midi_in || ~nvim_midi_in) {
    if(~stopMidiToOsc != nil) { ~stopMidiToOsc.value; };
    ~stopMidiToOsc = {
        on.free;
        off.free;
        cc.free;
    };
};

if(~tidal_midi_out) {
    // ~midiOut1 = MIDIOut.newByName("02. Internal MIDI", "02. Internal MIDI");
    // ~dirt.soundLibrary.addMIDI(\midi1, ~midiOut1);

    // ~midiOut2 = MIDIOut.newByName("UltraLite mk3 Hybrid", "UltraLite mk3 Hybrid");
    // ~dirt.soundLibrary.addMIDI(\midi2, ~midiOut2);

    // ~midiOut3 = MIDIOut.newByName("MIDIOUT2 (LPProMK3 MIDI)", "MIDIOUT2 (LPProMK3 MIDI)");
    // ~dirt.soundLibrary.addMIDI(\midi3, ~midiOut3);
};
)
