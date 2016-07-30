#============================================================= -*-Perl-*-
#
# MmrPm::Develop::DataLayout::Formats::Draft_000
#
# DESCRIPTION
#   Base example
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

package MmrPm::Develop::DataLayout::Formats::Draft_000;

use Moose;    # or this or both?
use Data::Dumper;

#
our $VERSION = 0.01;
use constant DATA_FORMAT_VERSION => "Draft_000";

#------------------------------------------------------------------------
#
#------------------------------------------------------------------------
sub get_ep_v1 {
  my $self  = shift;
  my @teams = (
    {
      name   => 'Man Utd',
      played => 16,
      won    => 12,
      drawn  => 3,
      lost   => 1
    },
    {
      name   => 'Bradford',
      played => 16,
      won    => 2,
      drawn  => 5,
      lost   => 9
    }
  );

  my %data = (
    name   => 'English Premier League',
    season => '2000/01',
    teams  => \@teams
  );

  return \%data;
}

sub show {
  my ( $self, $dataRef ) = @_;
  return Dumper($dataRef);
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
