#============================================================= -*-Perl-*-
#
# MmrPm::controller
#
# DESCRIPTION
#   Main controller. This provides all the sequencing and version selection
#   loading. Not super exiting stuff but important.
#   Blocks can be nested in the config see Draft_003 for example.
#
#
#
# AUTHOR
#   JAEM   <andy@thewindop.com>
#
# COPYRIGHT
#   Copyright (C) 2016 JAEM. All Rights Reserved.
#
#   This module is free software; you can redistribute it and/or
#   modify it under the same terms as Perl itself.
#
#============================================================================
package MmrPm::controller;

use Moose;
use Module::PluginFinder;
use Data::Dumper;
use JSON;

extends 'MmrPm::Processors::HouseKeeping::houseKeeping_v1';

sub runMmr {
  my ( $self, $mmr ) = @_;

  # Populate the test data hash. This happens by default. May be overridden
  # by incoming data.
  $mmr->{dev} = testDataFormatFactory( $mmr->{cfg}{format} );

  #------------------------------------------------------------------------
  # get the configuration
  #------------------------------------------------------------------------
  if ( $mmr->{cfg}{json} ne '' ) {
    if ( -d $mmr->{cfg}{json} ) {

      # Process all JSON files in directory
      # add a filter option here

      opendir( my $dh, $mmr->{cfg}{json} ) || die "Can't open $mmr->{cfg}{json}: $!";
      while ( readdir $dh ) {
        my $temp = $_;
        if ( lc($temp) =~ m/.*\.json$/ ) {
          print ("$_\n");
#          $mmr->{data}{ep} = JSON->new->pretty->decode( $self->readFileContents("$mmr->{cfg}{json}/$_") );
        }
      }
      closedir $dh;
    } else {

      # Process single JSON file
      #      my $fileContent = $self->readFromFile( $mmr->{cfg}{json} );
      $mmr->{data}{ep} = JSON->new->pretty->decode( $self->readFileContents( $mmr->{cfg}{json} ) );
    }
  } else {

    # development test module formats in PERL
    $mmr->{data}{ep} = $mmr->{dev}->get_ep_v1();
  }

  #------------------------------------------------------------------------
  # Dump the configuration
  #------------------------------------------------------------------------
  if ( $mmr->{cfg}{writecfg} ne "" ) {
    my $tmp = JSON->new->pretty->encode( $mmr->{data}{ep} );
    $tmp =~ s/\n[\s]{15}/ /g;
    $tmp =~ s/\n[\s]{12}\}/\} /g;

    #    print $tmp;
    $self->writeToFile( $mmr->{cfg}{writecfg}, $tmp );
  }

  #------------------------------------------------------------------------
  # template processing
  # Check
  # populate missing defaults
  # Build output lists
  #------------------------------------------------------------------------
  # Create the template processor
  my $tp = testTemplateProcessorFactory( $mmr->{cfg}{pversion} );

  # This builds a hash reference tree for procesing that contains a
  # reference to the top level config and block configs. This is a list
  # that allow us to call teh same subroutine for each, even if the config
  # is nested, which is valid.
  my $forProcessing = examineHashForBlockConfigs( $mmr->{data}{ep}, $tp );
  print Dumper($forProcessing) if ( $mmr->{cfg}{dumpcfg} );

  # Get the top level name. Turn this into a sub. We use this lots
  my $topName = "ERROR";
  if ( exists $forProcessing->{top} ) {
    my @block = ( keys( %{ $forProcessing->{top} } ) );
    $topName = $block[0];
  }

  # add all calculated fields here.
  $tp->checkBlockConfiguration( $self, $forProcessing, $topName );

  # generate all string for template inslusion
  $tp->generateBlockTemplateInserts( $forProcessing, $topName );

  # Process the top level, this one is slightly different as it contains
  # settings that may apply to other blocks. This is the only block allowed
  # to do this and is expected right at the top of the configuration.
  #  my $topName;
  if ( exists $forProcessing->{top} ) {

    #    my @block = ( keys( %{ $forProcessing->{top} } ) );
    #    $topName = $block[0];
    # Note the nested de-referenceing here, this is a bit of pig in perl,
    # but needs to be done.
    ${ $forProcessing->{top}{$topName} }->{cfg}{module} = $topName;
    ${ $forProcessing->{top}{$topName} }->{cfg}{ftype}  = "v";
    $tp->processBlock( $topName, $forProcessing->{top}{$topName}, $forProcessing->{top}{$topName}, $mmr->{cfg} );
  }

  # loop over the rest of the blocks
  if ( exists $forProcessing->{sb} ) {
    foreach my $block ( keys( %{ $forProcessing->{sb} } ) ) {
      ${ $forProcessing->{sb}{$block} }->{cfg}{module} = "${topName}_${$forProcessing->{sb}{$block}}->{cfg}{name}";
      ${ $forProcessing->{sb}{$block} }->{cfg}{ftype}  = "v";
      $tp->processBlock( $block, $forProcessing->{sb}{$block}, $forProcessing->{top}{$topName}, $mmr->{cfg} );
    }
  }

  #  $tp->dumpData($forProcessing);

  use Data::Dumper;
  $Data::Dumper::Purity   = 0;    # avoid cross-refs
  $Data::Dumper::Maxdepth = 6;    # no deeper than 3 refs down

  #  print Dumper($forProcessing);

  #------------------------------------------------------------------------
  # Manual template processing... Need to revisit this. Can we easily
  # support this? Its a debug feature so would be good to
  ##------------------------------------------------------------------------
  #use Template;
  #my $output = "";
  #my $tt = Template->new( EVAL_PERL => 1 );
  #$tt->process( $mmr->{cfg}{template}, $mmr->{data}{ep}, \$output ) || die $tt->error;
  #print $output;

  #MmrPm::Develop::processors::mmr_template_processor_v1

}

#------------------------------------------------------------------------
# templateFactory
# Search the template directories for relevent templates.
#------------------------------------------------------------------------

sub templateFactory {
  my ($type) = @_;
  return commonFactory( 'MmrTemplates::register', $type );
}

#------------------------------------------------------------------------
# testTemplateProcessorFactory
# Search the dataLayout directory for matching examples
#------------------------------------------------------------------------

#sub testTemplateProcessorFactory {
#  my ($version) = @_;
#  return commonFactory( 'MmrPm::Processors', "mmr_template_processor_${version}" );
#}

#------------------------------------------------------------------------
# testTemplateProcessorFactory
# Search the dataLayout directory for matching examples
#------------------------------------------------------------------------

sub testTemplateProcessorFactory {
  my ($version) = @_;
  return commonFactory( 'MmrPm::Processors', "mmr_template_processor_${version}" );
}

#------------------------------------------------------------------------
# testDataFormatFactory
# Search the dataLayout directory for matching examples
#------------------------------------------------------------------------

sub testDataFormatFactory {
  my ($type) = @_;
  return commonFactory( 'MmrPm::Develop::DataLayout::Formats', $type );
}

#------------------------------------------------------------------------
# commonFactory
# Search the dataLayout directory for matching examples
# We can provide a fiter to match on a condition we choose!
#------------------------------------------------------------------------

sub commonFactory {
  my ( $search, $type ) = @_;
  my $finder = Module::PluginFinder->new(
    search_path => $search,
    filter      => sub {
      my ( $module, $searchkey ) = @_;
      if ( $module =~ m/$type/ ) {
        print "Using : $module\n";
        return 1;
      } else {
        print "Found : $module\n";
        return 0;
      }
    },
  );
  return $finder->construct($type);
}

#------------------------------------------------------------------------

=head
So we have a config, now what do we build. 2 rules. One there must be a 
cfg for the top level. Then one cfg for each other template to create.
We need to search these out!
processBlochHash => { 
                      0 => { top => topRef, block => topRef }
                      1 => { top => topRef, block => blk0Ref }
                      2 => { top => topRef, block => blk1Ref }
                      n => { top => topRef, block => supporting1Ref }
                    }
=cut

# get list of blocks for processing.
# The top block is seperately identified. This works as we keep all our
# data as a HOH
#------------------------------------------------------------------------

## wrapper for the recurser,
sub examineHashForBlockConfigs {
  my ( $hash, $tp ) = @_;
  my %refsHash;    # hash ref counter, used to prevent/detect circular refs
  my $depth = 0;   # Track the depth to identify top config
  my %linkHash;    # hash to store links to
  examineHashRecurse( \%refsHash, $hash, $hash, $depth, \%linkHash, $tp );
  if ( !exists $linkHash{top} ) {
    print "Error there is no top level configuration. Check input. Cannot continue\n";
    exit();
  }
  return \%linkHash;
}

## recurser!
sub examineHashRecurse {
  my ( $refsHash, $hash, $lastElement, $depth, $linkHash, $tp ) = @_;
  $depth++;        # Track depth to confirm top config
  foreach my $key ( sort { $a cmp $b } keys( %{$hash} ) ) {

    # Actions to perform at this level
    recurserDealWithKey_cfg( $key, $hash, $lastElement, $depth, $linkHash, $tp );
    recurserDealWithKey_blocks( $key, $hash, $lastElement, $depth, $linkHash, $tp );

    # The recursive hash search
    if ( ( $$hash{$key} . "" ) =~ /HASH\(/ ) {
      if ( !exists $$refsHash{ $$hash{$key} } ) {

        # This provides some circular ref protection.
        $$refsHash{ $$hash{$key} } = 1;
        examineHashRecurse( $refsHash, $$hash{$key}, $$hash{$key}, $depth, $linkHash, $tp );
      } else {
        $$refsHash{ $$hash{$key} }++;
      }
    }
  }
}

## !
sub recurserDealWithKey_cfg {
  my ( $key, $hash, $lastElement, $depth, $linkHash, $tp ) = @_;

  #    print "$depth $key $$hash{$key} $lastElement\n";
  # This may be a bit crude, but if an issue we can update. If the tag if cfg and level==1
  # it must be the top level config, of which there can only be one.
  # For each additional block that we need to create they must have a cfg key that must
  # exist directly under a placeholder for that object and alongside other setting for that
  # object. This is passed around by lastElement
  if ( $key eq "cfg" ) {
    my $ename = $depth == 1 ? "top" : "sb";
    $linkHash->{$ename}{ $$hash{$key}{name} } = \$lastElement;

    #print "$$hash{$key}{name} $lastElement\n";
  }

}

## !
sub recurserDealWithKey_blocks {
  my ( $key, $hash, $lastElement, $depth, $linkHash, $tp ) = @_;

  # Provide counts for all the blocks at this level of hierarchy. These may be
  # required by templates when stitching the various blocks together.
  #
  if ( $key eq "blocks" ) {

    # Create type counts for each block in the config level
    my $regstrobes = 0;
    my $refifblock = 0;
    foreach my $lBlock ( sort { $a cmp $b } keys( %{ $hash->{$key} } ) ) {
      my $lType   = $hash->{$key}{$lBlock}{cfg}{type};
      my $lName   = $hash->{$key}{$lBlock}{cfg}{name};
      my $lEnable = $hash->{$key}{$lBlock}{cfg}{enable};

=head
This looks confusing, but is just creating the block count. A dump of the structure
should loook like this. regstrobes can be iterated over and also contains a link
to the config hash for that block so you can check settings.

I didnt like what I was doing here.....types should be selected in the template

          'work' => {
                      'counts' => {
                                    'blocks' => 3
                                  },
                      'widths' => {
                                    'signal' => 17,
                                    'bus' => 8
                                  },
                      'regstrobes' => {
                                        '1' => 'b1',
                                        '0' => 'b0'
                                      }
                    },
=cut

      #      if ( $tp->typeRequiresRegRwStrobes($lType) & $lEnable ) {
      #        $lastElement->{cfg}{work}{regstrobes}{ $regstrobes++ } = $lName;
      #      }

      # Provide a reference to the blocks master
      $hash->{$key}{$lBlock}{cfg}{master} = $lastElement->{cfg}{name};
    }
  }

}

1;

__END__

=head1 NAME

MmrPm::Develop::DataLayout::Formats::Draft_001 - Draft data structure

=head1 SYNOPSIS


=head1 DESCRIPTION
=head1 AUTHOR

JAEM E<lt>andy@thewindop.comE<gt> L<http://www.thewindop.com/>

=head1 COPYRIGHT

Copyright (C) 2016 JAEM. All Rights Reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO
=cut

# Local Variables:
# mode: perl
# perl-indent-level: 4
# indent-tabs-mode: nil
# End:
#
# vim: expandtab shiftwidth=4:
