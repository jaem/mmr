#!/opt/local/bin/perl

use strict;
use warnings;
use Getopt::Long;
use MmrPm::controller;
use FindBin qw($Bin);

#------------------------------------------------------------------------
# This call returns a hash reference. All further varibles are stored to
# this hash
#------------------------------------------------------------------------

my $mmrConfig  = processIoArgs();
my $controller = MmrPm::controller->new();
$controller->runMmr($mmrConfig);

#------------------------------------------------------------------------
# processIoArgs
#------------------------------------------------------------------------

sub processIoArgs {
  my %mmr;    # Declare the Hash of settings we will return
              #
              # Defaults of all our hash settings
              #
  $mmr{cfg}{template} = '';                # Tempate to use : DEBUG ONLY
  $mmr{cfg}{pversion} = "v1";              # Version of the template processor to use. Generally DEBUG ONLY
  $mmr{cfg}{format}   = "Draft_005";       # Default draft to use. Applied is no JSON is supplied. Generally DEBUG ONLY
  $mmr{cfg}{format}   = "";                # Default draft to use. Applied if no JSON is supplied. Generally DEBUG ONLY
                                           #
                                           # Things to care about
                                           #
  $mmr{cfg}{json}     = "";                # JSON input register description
  $mmr{cfg}{writecfg} = '';                # Write out the config to this location.
  $mmr{cfg}{outdir}   = '../../mmrOut';    # Base dir for generated output
  $mmr{cfg}{dumpcfg}  = 0;                 # Display config to screen. Generally DEBUG of input JSON
                                           #
                                           # Useful
                                           #
  $mmr{cfg}{exepath}  = $Bin;              # Path to here!!
  $mmr{cfg}{help}     = 0;                 # Print help text
                                           #
                                           # Code that does command line updates
                                           #
  my $argcnt = @ARGV;
  GetOptions(
    "template=s" => \$mmr{cfg}{template},    #
    "pversion=s" => \$mmr{cfg}{pversion},    #
    "format=s"   => \$mmr{cfg}{format},      #
    "json=s"     => \$mmr{cfg}{json},        #
    "writecfg=s" => \$mmr{cfg}{writecfg},    #
    "outdir=s"   => \$mmr{cfg}{outdir},      #
    "dumpcfg"    => \$mmr{cfg}{dumpcfg},     #
    "help"       => \$mmr{cfg}{help}         #
  ) or die("Error in command line arguments\n");
  #
  showHelp() if ( $mmr{cfg}{help} or ( $argcnt == 0 ) );
  #
  # tweaks
  #
  $mmr{cfg}{outdir} =~ s/\/$//;                         # remove trailing slash
  return \%mmr;                                         # Return a reference to this hash.
}

sub showHelp {
  my $helpTxt = "
  mmr : Make Me Registers! (and all the useful bits that go with that!!!)

  -json <string>       e.g. ../../xxxx.json  // JSON file with register description
  -writecfg <fileName> e.g. ./xxx.json       // Write config back to a json file
  -outdir <dirPath>    e.g. ../../xxxx       // Generate output in this directory
  
  -format <string>     e.g. Draft_005        // Built in test formats
  -dumpcfg                                   // Dump the internal hash at multiple build points (DEBUG)
  
                                             // Build example registers
  ./mmr.pl -json ./MmrTest/exampleJson/pulseMeasureBank.json
  
                                             // Print help text
  ./mmr.pl
  ./mmr.pl -help

";
  print $helpTxt;
  exit();
}
