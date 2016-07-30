#============================================================= -*-Perl-*-
#
# MmrPm::Develop::DataLayout::Formats::Draft_001
#
# DESCRIPTION
#   Plugin that returns verilog register
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

package MmrPm::Processors::mmr_template_processor_v1;

use Moose;
use Template;

extends 'MmrPm::Processors::HouseKeeping::houseKeeping_v1',     # Data dumper and File IO
  'MmrPm::Processors::BlockProcessors::HdlVerilogStringGen',    # Register string logic
  'MmrPm::Processors::BlockProcessors::RegAccessDecisions';     # decisions for actions on register type

has 'controller' => ( is => 'rw', );                            # A reference to the main contoller. Could be removed!

sub checkBlockConfiguration {
  my ( $self, $controllerRef, $dataRef, $topName ) = @_;
  $self->controller($controllerRef);                            # Not sure we need this reference!

  # gen counts of inputs & outputs
  # cal signal widths

  # To save the constant dereferencing, create these alias's
  my $topCfgRef = ${ $dataRef->{top}{$topName} }->{cfg};

  # Track signal widths so we can auto align the output.
  $topCfgRef->{work}{widths}{signal} = 0 if ( !exists $topCfgRef->{work}{widths}{signal} );
  $topCfgRef->{work}{widths}{bus}    = 0 if ( !exists $topCfgRef->{work}{widths}{bus} );

  $topCfgRef->{work}{counts}{blocks} = 0 if ( !exists $topCfgRef->{work}{counts}{blocks} );

  #  print $self->dumpData($dataRef);
  foreach my $block ( keys %{ $dataRef->{sb} } ) {

    $topCfgRef->{work}{counts}{blocks}++;

    # watch the has dereference here ${...}->{} DataDumper is useful
    # for debug here!!
    if ( exists ${ $dataRef->{sb}{$block} }->{reg} ) {

      #      print $self->dumpData( $dataRef->{sb}{$block} );
      foreach my $signal ( keys %{ ${ $dataRef->{sb}{$block} }->{reg} } ) {

        # To save the constant dereferencing, create these alias's
        my $sigRef    = ${ $dataRef->{sb}{$block} }->{reg}{$signal};
        my $blkCfgRef = ${ $dataRef->{sb}{$block} }->{cfg};

        # Initial counts
        $blkCfgRef->{work}{counts}{input}  = 0 if ( !exists $blkCfgRef->{work}{counts}{input} );
        $blkCfgRef->{work}{counts}{output} = 0 if ( !exists $blkCfgRef->{work}{counts}{output} );

        # Concat the width onto the string as when we declare the width we can
        # ensure there is enough space in the firld for the biggest declaration
        $topCfgRef->{work}{widths}{signal} = length($signal) if ( length($signal) > $topCfgRef->{work}{widths}{signal} );
        my $sigAssign = "[$sigRef->{width}:$sigRef->{offset}]  ";
        $topCfgRef->{work}{widths}{bus} = length($sigAssign) if ( length($sigAssign) > $topCfgRef->{work}{widths}{bus} );

        # Count the signal types
        $blkCfgRef->{work}{counts}{input}++  if ( $self->isSignalInput( $sigRef->{type} ) );
        $blkCfgRef->{work}{counts}{output}++ if ( $self->isSignalOutput( $sigRef->{type} ) );

        # does signal have a reset exclude field?
        $sigRef->{rst} = 1 if ( !exists $sigRef->{rst} );
      }
    }
  }

  #  print $self->dumpData($dataRef);
}

=head
these all need to be put in a separate block as saparate routines!
=cut

sub generateBlockTemplateInserts {
  my ( $self, $dataRef, $topName ) = @_;

  # To save the constant dereferencing, create these alias's
  my $topCfgRef = ${ $dataRef->{top}{$topName} }->{cfg};

  foreach my $block ( keys %{ $dataRef->{sb} } ) {

    my $masterCfgRef = $self->CreateBlockTypeReferenceForEachMaster( $dataRef, $topName, $topCfgRef, $block );

    # watch the has dereference here ${...}->{} DataDumper is useful
    # for debug here!!
    if ( exists ${ $dataRef->{sb}{$block} }->{reg} ) {

      foreach my $signal ( keys %{ ${ $dataRef->{sb}{$block} }->{reg} } ) {

        # To save the constant dereferencing, create these alias's
        my $sigRef    = ${ $dataRef->{sb}{$block} }->{reg}{$signal};
        my $blkCfgRef = ${ $dataRef->{sb}{$block} }->{cfg};

        # Get the address for the case with the appropiate number of bits removed for
        # a 32 or 64 address space
        my $addr = $self->retCaseAddr( $blkCfgRef, $sigRef );

        # Build a list of the inputs/outputs that leave the bank as signals
        if ( $self->isSignalInput( $sigRef->{type} ) ) {

          $self->doInputSIgnalProcessing( $topCfgRef, $block, $sigRef, $blkCfgRef, $masterCfgRef, $addr, $signal );

        }

        if ( $self->isSignalOutput( $sigRef->{type} ) ) {

          $self->doOutputSIgnalProcessing( $topCfgRef, $block, $sigRef, $blkCfgRef, $masterCfgRef, $addr, $signal );

        }
      }
    }
  }

  #  print $self->dumpData($dataRef);
}

sub doOutputSIgnalProcessing {
  my ( $self, $topCfgRef, $block, $sigRef, $blkCfgRef, $masterCfgRef, $addr, $signal ) = @_;

  # Register declaration for register
  $blkCfgRef->{work}{outputreg}{$signal} = $self->buildRegPortDec( $topCfgRef, $sigRef, $signal, "${block}_" );

  # output declaration for hierarchly levels above
  $masterCfgRef->{work}{outsigs}{$block}{$signal} = $self->buildWirePortDec( $topCfgRef, $sigRef, $signal, "${block}_" );

  # instance declaration for hierarchly levels above
  $masterCfgRef->{work}{hier_outsigs}{$block}{$signal} = $self->buildInstanceConnection( $topCfgRef, $sigRef, $signal, "${block}_" );

  # Reset value assignment
  $blkCfgRef->{work}{regreset}{$signal} = $self->buildRegResetValue( $topCfgRef, $sigRef, $signal, "" );

  # Resister write assignment
  $blkCfgRef->{work}{regwrite}{$addr}{$signal} = $self->buildRegWriteValue( $topCfgRef, $sigRef, $signal, "" );

  if ( $self->isSignalReadable( $sigRef->{type} ) ) {

    # register read assigment, when applicable.
    $blkCfgRef->{work}{regread}{$addr}{$signal} = $self->buildRegReadValue( $topCfgRef, $sigRef, $signal, "" );
  }
  return $masterCfgRef;
}

sub doInputSIgnalProcessing {
  my ( $self, $topCfgRef, $block, $sigRef, $blkCfgRef, $masterCfgRef, $addr, $signal ) = @_;
  $blkCfgRef->{work}{inputwire}{$signal} = $self->buildWirePortDec( $topCfgRef, $sigRef, $signal, "" );
  $masterCfgRef->{work}{insigs}{$block}{$signal} = $self->buildWirePortDec( $topCfgRef, $sigRef, $signal, "${block}_" );
  $masterCfgRef->{work}{hier_insigs}{$block}{$signal} = $self->buildInstanceConnection( $topCfgRef, $sigRef, $signal, "${block}_" );

  $blkCfgRef->{work}{regread}{$addr}{$signal} = $self->buildRegReadValue( $topCfgRef, $sigRef, $signal, "" );
  return $masterCfgRef;
}

sub CreateBlockTypeReferenceForEachMaster {
  my ( $self, $dataRef, $topName, $topCfgRef, $block ) = @_;

  # Create a block type reference for each master block
  my $masterCfgRef = 0;
  if ( exists $dataRef->{sb}{$block} ) {
    my $myMaster = ${ $dataRef->{sb}{$block} }->{cfg}{master};
    if ( !exists $dataRef->{sb}{$myMaster} ) {
      if ( exists $dataRef->{top}{$myMaster} ) {
        ${ $dataRef->{top}{$myMaster} }->{cfg}{work}{blks}{$block} = ${ $dataRef->{sb}{$block} }->{cfg}{type};
        $masterCfgRef = ${ $dataRef->{top}{$myMaster} }->{cfg};
      } else {
        print " We have an issue\n";
      }
    } else {
      ${ $dataRef->{sb}{$myMaster} }->{cfg}{work}{blks}{$block} = ${ $dataRef->{sb}{$block} }->{cfg}{type};
      $masterCfgRef = ${ $dataRef->{sb}{$myMaster} }->{cfg};
    }
  }
  return $masterCfgRef;
}

#------------------------------------------------------------------------
# Select template, process and write out result.
#------------------------------------------------------------------------

sub processBlock {
  my ( $self, $name, $blockData, $topData, $cfgData ) = @_;
  printf( "Processing block %-30s of type %s\n", $name, $$blockData->{cfg}{type} );

  $self->dumpData( $$topData->{cfg} ) if ( $cfgData->{dumpcfg} );
  $self->dumpData($blockData) if ( $cfgData->{dumpcfg} );

  my $template = $self->getTemplate( $name, $blockData, $cfgData );

  $$blockData->{topcfg} = $$topData->{cfg};    # add a reference to the top cfg data

  my $output = $self->processTemplate( $template, $blockData );

  my ( $outFilePath, $outFileName ) = $self->getOutFileName( $name, $blockData, $topData, $cfgData );
  $self->writeResultToFile( $outFilePath, $outFileName, $output );
}

#------------------------------------------------------------------------
# Get the correct template, build as <typeName>_<formatType>_<version>
# This will get more complex. We also want to search a under dir.
# maybe just change our find to a recursive find on a list of directories
# starting with user's then the builting, MmrTemplates.
#------------------------------------------------------------------------

sub getTemplate {
  my ( $self, $name, $blockData, $cfgData ) = @_;
  my $template = "$$blockData->{cfg}{type}_$$blockData->{cfg}{version}.tp";

  # Add a multiple dir search here
  my $fullPath = "MmrTemplates/register/$template";
  if ( !-f $fullPath ) {
    print "Error template does not exist for $fullPath\n";
    exit();
  }
  return $fullPath;

}

#------------------------------------------------------------------------
# Call the template processing, return result as a string
#------------------------------------------------------------------------

sub processTemplate {
  my ( $self, $fullPath, $blockData ) = @_;
  my $output = "";                            # Passed as a reference!
  my $tt = Template->new( EVAL_PERL => 1 );
  $tt->process( $fullPath, $$blockData, \$output ) || die $tt->error;
  return $output;
}

#------------------------------------------------------------------------
# The filename is a concatanation of the top name and block name
#------------------------------------------------------------------------

sub getOutFileName {
  my ( $self, $name, $blockData, $topData, $cfgData ) = @_;
  my $outFilePath = $cfgData->{outdir} . "/${$blockData}->{cfg}{ftype}";
  my $outFileName = "${$blockData}->{cfg}{module}.${$blockData}->{cfg}{ftype}";
  return ( $outFilePath, $outFileName );
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
