#!/usr/bin/perl

# PERL modules
use Getopt::Long;
use File::Path qw(make_path);
use DateTime;
use FindBin qw($Bin);

my %configHash;
initialiseConfigHash( \%configHash );

GetOptions(
  "outDir=s"  => \$configHash{outDir},
  "exeCmds"   => \$configHash{exeCmds},
  "diffDir=s" => \$configHash{diffDir},
  "help"      => \$configHash{help},
);

# initialise script configuration.
sub initialiseConfigHash {
  my ($configHash) = @_;
  $$configHash{keyName} = "mmrRelease_";
  $$configHash{outDir}  = "${Bin}/../../../mmrRelease";
  $$configHash{diffDir} = "";
  $$configHash{exeCmds} = 0;
  $$configHash{help}    = 0;
}

&printHelpText( \%configHash ) if ( $configHash{help} );

my $dirName = $configHash{keyName} . &getDateStamp();
$configHash{outDir} = $configHash{outDir} . "/$dirName";

if ( !-e $configHash{outDir} ) {
  make_path( $configHash{outDir} );
}

system("cp -R " . "MmrPm " . $configHash{outDir} . "/.");
system("cp -r " . "MmrTemplates " . $configHash{outDir} . "/.");
system("cp -r " . "mmr.pl " . $configHash{outDir} . "/.");
system("cp -r " . "releaseMmr.pl " . $configHash{outDir} . "/.");

&executeCommand( $configHash{exeCmds}, "find $configHash{outDir} | xargs cat > numberOfLinesOfCode;wc -l numberOfLinesOfCode;rm numberOfLinesOfCode" );
&executeCommand( $configHash{exeCmds}, "ls -la $configHash{outDir}" );
&executeCommand( $configHash{exeCmds}, "tar -czf $configHash{outDir}/../$dirName.tarz -C $configHash{outDir}/ ../$dirName" );

&diffDirCheck( $configHash{outDir}, $configHash{diffDir} );

sub diffDirCheck {

  my ( $dirA, $dirB ) = @_;

  if ( $dirB ne "" ) {

    $command   = "diff -r $dirA $dirB | grep diff";
    $tkdiffCmd = "/Applications/TkDiff.app/Contents/MacOS/tkdiff";

    open DATA, "$command |" or die "Couldn't execute program: $!";
    while ( defined( my $line = <DATA> ) ) {
      chomp($line);
      $line =~ s/diff\s+-r//;
      push @commands, "$tkdiffCmd $line";
    }
    close DATA;

    system $_ foreach @commands;

    # Came across this on perl monks, useful for scripts that will take hours
    #		my $process = Expect->spawn($command) or die "Cannot spawn $command: $!\n";
    #
    #		while ( $process->expect(undef) ) {
    #			print "tddddddddddk" . $process->before();
    #		}
  }
}

sub executeCommand {
  my ( $execute, $command ) = @_;
  print("$command\n");
  system("$command") if $execute;
}

sub performExportOnDir {
  my ( $pathIn, $dirIn, $pathOut, $forceExecuteable ) = @_;
  system("svn export $pathIn/$dirIn $pathOut/$dirIn");
  if($forceExecuteable){
    # added this exe force after some svn weirdness!
    system("chmod +x $pathOut/$dirIn/*");
  }
}

sub getDateStamp {
  $dt = DateTime->now( time_zone => 'UTC' );
  return $dt->ymd('') . "_" . $dt->hms('');
}

sub printHelpText {
  my ($hashhash) = @_;

  print "Options:\n";
  foreach ( sort { $a cmp $b } keys( %{$hashhash} ) ) {
    printf "    %-20s : %-30s\n", $_, $$hashhash{$_};
  }

  $helpText = <<LOOKFOREND;

This script exports from SVN all the data required for the www processing script.

Install requirements:

  cpanm install 

Update protcol is:
    Create release
    Use -diffDir to compare the new release to a known directory release

LOOKFOREND
  print $helpText;

  exit;
}
