#!/opt/local/bin/perl

use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin";
use Getopt::Long;
use MmrPm::controller;

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
  $mmr{cfg}{debug}    = "NOMATCH";         # Debug, show data structure
  $mmr{cfg}{funky}    = 0;                 # Display config to screen. Generally DEBUG of input JSON
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
    "funky"      => \$mmr{cfg}{funky},     #
    "template=s" => \$mmr{cfg}{template},  #
    "pversion=s" => \$mmr{cfg}{pversion},  #
    "format=s"   => \$mmr{cfg}{format},    #
    "input=s"    => \$mmr{cfg}{json},      #
    "writecfg=s" => \$mmr{cfg}{writecfg},  #
    "outdir=s"   => \$mmr{cfg}{outdir},    #
    "debug=s"    => \$mmr{cfg}{debug},     #
    "help"       => \$mmr{cfg}{help}       #
  ) or die("Error in command line arguments\n");
  #
  showHelp() if ( $mmr{cfg}{help} or ( $argcnt == 0 ) );
  funky(\%mmr) if ( $mmr{cfg}{funky} );
  #
  # tweaks
  #
  $mmr{cfg}{outdir} =~ s/\/$//;            # remove trailing slash
  return \%mmr;                            # Return a reference to this hash.
}

sub funky {
  my $mmr = shift;
  # Build in test mode
  $mmr->{cfg}{json} = "$mmr->{cfg}{exepath}/MmrTest/exampleJson/pulseMeasureBank.json";
  $mmr->{cfg}{writecfg} = "funky.json";
}

sub showHelp {
  my $helpTxt = "
  mmr : Make Me Registers! (and all the useful bits that go with that!!!)

  -format <string>     e.g. Draft_005        // Built in test format, HASH constructed in subroutine. Developer only

  -input <string>      e.g. ../../xxxx.json  // JSON|YAML file with register description
  -writecfg <fileName> e.g. ./xxx.json       // Write config back to a json file
  -outdir <dirPath>    e.g. ../../xxxx       // Generate output in this directory
  -debug <regexp>      e.g. pre              // Dump the incoming config as read, pre any checking, fill in
                            post             // Dump the config after config has been check and default filled
                            <blockName>cfg   // Dump the config hash for the template being run
                            <blockname>data  // Dump the data hash for the template being run
  
                                             // Build example registers
  ./mmr.pl -input ./MmrTest/exampleJson/pulseMeasureBank.json
  
                                             // Print help text
  ./mmr.pl
  ./mmr.pl -help

";
  print $helpTxt;
  exit();
}
