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

package MmrPm::Develop::DataLayout::Formats::Draft_005;

use Moose;    # or this or both?
use Data::Dumper;

#
our $VERSION = 0.01;
use constant DATA_FORMAT_VERSION => "Draft_005";

#------------------------------------------------------------------------
# This is the most basic working example. See previous for more ideas
#------------------------------------------------------------------------
sub get_ep_v1 {
  my $self = shift;

  my %endpoint = (
    cfg => {
      name           => 'pc_ctrl',           # Name of block. Appended to all sub blocks, so keep short
      type           => "axi_top_bank_v",    # Type of template/HDL to use
      version        => '1',                 # Version of template/HDL to use
      enable         => 1,                   # Block enable
      tag            => '_a',                # Can I comment like this?
      resetActiveLow => 1,                   # Level for reset
      resetIsSync    => 1,                   # Main interface reset is Sync/Async
      addrLowWidth   => 8,                   # Low address width in bits
      addrHighWidth  => 2                    # High address width in bits
    },
    deps   => {},                            # Supporting templates/HDL required
    blocks => {                              # Integer to control order in HDL.
      0 => { cfg => { name => "axi4_reg_if", type => "axi4_reg_if_v", version => 1, enable => 1, tag => '' }, },
      1 => {
        cfg => { name => "pm0", type => "reg_sync_v", version => 1, enable => 1, tag => '', decode => 0 },
        reg => {
          enable           => { type => "rw", addr => 0x00, width => 1,  offset => 0, def => 1,         clk => '', enable => 1, doc => '' },
          use_one_pps_in   => { type => "rw", addr => 0x04, width => 1,  offset => 0, def => 0,         clk => '', enable => 1, doc => '' },
          clk_freq         => { type => "rw", addr => 0x08, width => 32, offset => 0, def => 100000000, clk => '', enable => 1, doc => '' },
          clk_subsample    => { type => "rw", addr => 0x0C, width => 32, offset => 0, def => 0,         clk => '', enable => 1, doc => '' },
          pulse_per_second => { type => "ro", addr => 0x10, width => 16, offset => 0, def => 0,         clk => '', enable => 1, doc => '' },
          accum_low_period => { type => "ro", addr => 0x14, width => 32, offset => 0, def => 0,         clk => '', enable => 1, doc => '' },
          ready_to_read    => { type => "ro", addr => 0x18, width => 1,  offset => 0, def => 0,         clk => '', enable => 1, doc => '' },
        }
      },
      2 => {
        cfg => { name => "pm1", type => "reg_sync_v", version => 1, enable => 1, tag => '', decode => 0 },
        reg => {
          enable           => { type => "rw", addr => 0x00, width => 1,  offset => 0, def => 1,         clk => '', enable => 1, doc => '' },
          use_one_pps_in   => { type => "rw", addr => 0x04, width => 1,  offset => 0, def => 1,         clk => '', enable => 1, doc => '' },
          clk_freq         => { type => "rw", addr => 0x08, width => 32, offset => 0, def => 100000000, clk => '', enable => 1, doc => '' },
          clk_subsample    => { type => "rw", addr => 0x0C, width => 32, offset => 0, def => 0,         clk => '', enable => 1, doc => '' },
          pulse_per_second => { type => "ro", addr => 0x10, width => 16, offset => 0, def => 0,         clk => '', enable => 1, doc => '' },
          accum_low_period => { type => "ro", addr => 0x14, width => 32, offset => 0, def => 0,         clk => '', enable => 1, doc => '' },
          ready_to_read    => { type => "ro", addr => 0x18, width => 1,  offset => 0, def => 0,         clk => '', enable => 1, doc => '' },
          }
      }
    }
  );

  return \%endpoint;
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
