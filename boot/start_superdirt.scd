(
var file;
var config;

s.reboot {
    // s.options.device = "ASIO";
    // s.options.sampleRate = 48000;
    s.options.numBuffers = 1024 * 256;
    s.options.memSize = 8192 * 32;
    s.options.numWireBufs = 80;
    s.options.maxNodes = 1024 * 32;
    s.options.numOutputBusChannels = 2;
    s.options.numInputBusChannels = 2;

    s.waitForBoot {
        ~dirt.stop;
        ~dirt = SuperDirt(2, s);
        ~dirt.loadSoundFiles;

        if(File.exists("projectconfig.json")) {
            file = File("projectconfig.json", "r");
            config = file.readAllString.parseYAML;
            config["sampledirs"].do { |item, i| ~dirt.loadSoundFiles(item); };
        };

        // ~drumMachinesDir = PathName.new("F:\\Samples\\tidaldrummachines");
        // ~machines = ~drumMachinesDir.folders;
        // (
        //     ~machines.do { |machine|
        //         var folders = machine.folders;
        //         folders.do { |folder|
        //             ~dirt.loadSoundFiles(folder.fullPath, namingFunction: { |x| x.basename.replace("-", ""); });
        //         };
        //     };
        // );

        s.sync;
        ~dirt.start(57120, 0 ! 12);

        (
            ~d1 = ~dirt.orbits[0]; ~d2 = ~dirt.orbits[1]; ~d3 = ~dirt.orbits[2];
            ~d4 = ~dirt.orbits[3]; ~d5 = ~dirt.orbits[4]; ~d6 = ~dirt.orbits[5];
            ~d7 = ~dirt.orbits[6]; ~d8 = ~dirt.orbits[7]; ~d9 = ~dirt.orbits[8];
            ~d10 = ~dirt.orbits[9]; ~d11 = ~dirt.orbits[10]; ~d12 = ~dirt.orbits[11];
        );
    };

    s.latency = 0.1;
    // s.recHeaderFormat_("wav");
    // s.volume = -12;
};
)
