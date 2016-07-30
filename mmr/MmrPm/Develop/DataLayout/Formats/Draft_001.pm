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

package MmrPm::Develop::DataLayout::Formats::Draft_001;

use Moose;    # or this or both?
use Data::Dumper;

#
our $VERSION = 0.01;
use constant DATA_FORMAT_VERSION => "Draft_001";

#------------------------------------------------------------------------
#
#------------------------------------------------------------------------
sub get_ep_v1 {
  my $self = shift;

  my %endpoint = (
    cfg => {
      version        => '1.0',
      name           => 'example',
      tag            => '_a',                       # Can I comment like this?
      type           => "axi_top-bank",
      enable         => 1,                          # Block enable
      resetActiveLow => 1,                          #
      resetIsSync    => 1,                          #
      addrLowWidth   => 8,                          # Low address width
      addrHighWidth  => 2                           # Enough space must be left to decode all
    },
    com => {

      # Signal sets that are shared. Each set has a name tag that is then also
      # called within the com hash entry. After this they have the same syntax
      # as a sig
      # commonName => sig1 => {settings}
      #            => sig2 => {settings}
    },
    blocks => {                                     # Integer to control order
      0 => {
        cfg => {
          name   => "reg_if",
          type   => "axi4_reg_if",
          enable => 1,                              # Block enable
          tag    => '',                             # Can I comment like this?
        },

        # Interfaces will be defined somewhere global. Such as AXI4, APB, AXI4Lite, AXIS
        interfaces => {
          number => 0,                              # Number is populated at the end of unroll so the template can just apply it
          data   => {}
        },
        connData => {
          comSig => {                               # Shared signal sets. These are signals reguired for the
                                                    # template IO. Used to generation hierarchy instances.
                                                    # This can be unused
            number => 2,
            data   => {
              0 => 'reIo1',
              1 => 'reIo2'
            }
          },
          comReg => {                               # Shared register sets. Register sets that contain multiple
                                                    # registers. Unrolled into reg & regSig in order applied.
                                                    # These are applied after explicitly defined registers.
            number => 0,
            data   => { 0 => 'timeOutV1' }
          },
          ioSig => {                                # Signals required on the interface of this block. This can also be
                                                    # populated during check with the values in comSig
            number => 0,
            data   => {}
          },
          regSig => {                               # Registers that exist within the block. IO is implied from type
            number => 0,
            data   => {
              0 => {
                name   => "power_good",
                type   => "rw",
                addr   => 0x0,
                width  => 1,
                offset => 0,
                def    => 0,
                clkin  => '',
                clkout => '',
                enable => 1,
                doc    => ''
              },
              1 => {
                name   => "power_enable",
                type   => "rw",
                addr   => 0x4,
                width  => 1,
                offset => 0,
                def    => 0,
                clkin  => '',
                clkout => '',
                enable => 1,
                doc    => ''
              }
            }
          },
          regIoSig => {    # Registers IO populated during check before template handoff
            number => 0,
            data   => {}
          }
        }
      },
      1 => {
        cfg => {
          name   => "reg_if",
          type   => "axi4_reg_if",
          enable => 1,               # Block enable
          tag    => '',              # Can I comment like this?
        },
        sig => {

        },
        reg => {

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
