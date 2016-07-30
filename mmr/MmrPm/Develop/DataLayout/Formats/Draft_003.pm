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

package MmrPm::Develop::DataLayout::Formats::Draft_003;

use Moose;    # or this or both?
use Data::Dumper;

#
our $VERSION = 0.01;
use constant DATA_FORMAT_VERSION => "Draft_003";

#------------------------------------------------------------------------
# This shows a nested config working
#------------------------------------------------------------------------
sub get_ep_v1 {
  my $self = shift;

  my %endpoint = (
    cfg => {
      name           => 'example',         # Name of block. Appended to all sub blocks, so keep short
      type           => "axi_top-bank",    # Type of template/HDL to use
      version        => '1.0',             # Version of template/HDL to use
      enable         => 1,                 # Block enable
      tag            => '_a',              # Can I comment like this?
      resetActiveLow => 1,                 # Level for reset
      resetIsSync    => 1,                 # Main interface reset is Sync/Async
      addrLowWidth   => 8,                 # Low address width in bits
      addrHighWidth  => 2                  # High address width in bits
    },
    deps   => {},                          # Supporting templates/HDL required
    blocks => {                            # Integer to control order in HDL.
      0 => { cfg => { name => "axi4_reg_if", type => "axi4_reg_if", version => 1, enable => 1, tag => '' }, },
      1 => {
        cfg => { name => "b0", type => "reg_sync", version => 1, enable => 1, tag => '', decode => 0 },
        reg => {
          power_good   => { type => "rw", addr => 0x0, width => 1, offset => 0, def => 0, clk => '', enable => 1, doc => '' },
          power_enable => {
            type     => "rw",
            addr     => 0x4,
            width    => 1,
            offset   => 0,
            def      => 0,
            clk      => '',
            enable   => 1,
            doc      => '',
            subBlock => {

              cfg => { name => "gaot", type => "reg_sync", version => 1, enable => 1, tag => '', decode => 0 },
              reg => {
                power_good   => { type => "rw", addr => 0x0, width => 1, offset => 0, def => 0, clk => '', enable => 1, doc => '' },
                power_enable => {
                  type   => "rw",
                  addr   => 0x4,
                  width  => 1,
                  offset => 0,
                  def    => 0,
                  clk    => '',
                  enable => 1,
                  doc    => ''
                }
                }
            }
          }
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
