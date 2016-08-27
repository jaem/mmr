MMR = MakeMeRegisters

About

A templating tool to build Verilog register banks, C headers and other related files from a single description
file, generally JSON. The internal representation is held as a HOH in PERL. The JSON is a nice way to get this in.

Minimal input, maximum output is our aim.

Function status Table

|--------------------------------------------------------------------------------------------|  
|  Function              | Status | Comment                                                  |  
|------------------------|--------|----------------------------------------------------------|  
| Templates              |--------|----------------------------------------------------------|  
|                        |        |                                                          |  
|  Verilog               |--------|----------------------------------------------------------|  
|   Simple R/W           |   Y    | Basic RW register bank                                   |  
|   AXI4 Interface       |   Y    | AXI4 interface to Banks                                  |  
|   BankTopLevel         |   Y    | Bank stitching code                                      |  
|   Syncroniser          |   Y    | n element single bit syncroniser.                        |  
|   BasicTestBench       |   Y    | Simple bench to eyeball R/W.                             |  
|   AdvTestBench         |   N    | Bench that allows indepth test.SynthesiseableForHwTest   |  
|                        |        |                                                          |  
|  Other                 |--------|----------------------------------------------------------|  
|   CSV table            | N 16/9 | Use for basic documentation                              |  
|   .h MemoryMap         | N 16/9 |                                                          |  
|   .json MemoryMap      |   N    |                                                          |  
|   SpirtDesc            |   N    |                                                          |  
|                        |        |                                                          |  
-------------------------|--------|----------------------------------------------------------|  
| RegisterTypes          |--------|----------------------------------------------------------|  
|  BuiltInPulseRegs      |   N    | Allow single or multi clock pulses                       |  
|  XClockDomain          |   N    | Syncroniser elements inserted in line                    |  
|  ClearOnR/W            |   N    | Clear on read/write                                      |  
|                        |        |                                                          |  
-------------------------|--------|----------------------------------------------------------|  
| GUI                    |--------|----------------------------------------------------------|  
|  (mmr_rc)RegCature     |   N    | NodeJS GUI allowing fast register capture                |  
|  (mmr_rq)RegQuery      |   N    | NodeJS GUI allowing regexp reg map query                 |  
|  (mmr_rrw)RegReadWrite |   N    | Extension to RRW allow R/W via serial/TCL/BLE etc.       |  
|                        |        |                                                          |  
|--------------------------------------------------------------------------------------------|  

Why not XML? Its humanly unreadable after a point, you can argue this with JSON, but less so. MMR is aimed at 
being able to script register flows or quickly human hack.

Why not use SPIRIT? You can generate a SPIRIT compatable output if you like, but again, its a pain to input.

History

Generating register code is someting I hate. But I want registers to be meaningful and easy to augment.
So after working at a few different companies, writing this a few differnt times, here is a free core
of how I like to work and a flexible approach to creating HDL that you can use in any project.

The tool is written in PERL, maybe unfashonable at present, but guaranteed to be used in all major HDL tech companies.

CPAN Dependicies

sudo cpan install Template
sudo cpan install Module::PluginFinder
sudo cpan install JSON::Parse

Usage

Use a build in test format. Generally these are for development.

./mmr.pl -t ./templates/d./mmr.pl -format Draft_005 -out ./../work/mmrOutputDir_003 -write ./../exampleOut.json



