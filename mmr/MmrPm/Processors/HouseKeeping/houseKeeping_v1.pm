#============================================================= -*-Perl-*-
#
# MmrPm::Processors::HouseKeeping::houseKeeping_v1
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
package MmrPm::Processors::HouseKeeping::houseKeeping_v1;

use Moose;
use Data::Dumper;
use File::Path qw(make_path);

sub dumpData {
  my ( $self, $dataRef ) = @_;
  print Dumper ($dataRef);
}

=head
Get the contens of a file as a string
=cut
sub readFileContents {
  my ( $self, $fileName ) = @_;
  my $return = "";
  open( FILE, "$fileName" ) || die "Can't open $fileName: $!\n";
  my @temp = <FILE>;
  close(FILE);
  $return = join '', @temp;
  return $return;
}

sub writeResultToFile {
  my ( $self, $outFilePath, $outFileName, $output ) = @_;
  print "Writing output to $outFilePath/$outFileName\n";
  $self->didWeNeedToCreatePath($outFilePath);
  $self->writeToFile( "$outFilePath/$outFileName", $output );
}

sub writeToFile {
  my ( $self, $fileName, $string ) = @_;
  if ( $fileName ne "" ) {
    open( FILE, ">$fileName" ) || die "Can't open $fileName: $!\n";
    print FILE $string;
    close(FILE);
  }
}

sub didWeNeedToCreatePath {
  my ( $self, $path ) = @_;
  my $return = 0;
  if ( !-e $path ) {
    print("Had to create path $path in $self\n");
    make_path($path);
    $return = 1;
  }
  return $return;
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
