#============================================================= -*-Perl-*-
#
# MmrPm::Register::Verilog
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

package MmrPm::Register::Hdl::Verilog::Assignments;

use base 'Template::Plugin';    # Can use this
use Moose;                      # or this or both?
use Data::Dumper;
#
our $VERSION = 0.01;

#------------------------------------------------------------------------
# goat()
#
#------------------------------------------------------------------------

sub show {
  my ($self, $dataRef) = @_;
  return Dumper($dataRef);
}

1;

__END__

=head1 NAME

Template::Plugin::Table - Plugin to present data in a table

=head1 SYNOPSIS


=head1 DESCRIPTION
=head1 AUTHOR

Andy Wardley E<lt>abw@wardley.orgE<gt> L<http://wardley.org/>

=head1 COPYRIGHT

Copyright (C) 1996-2007 Andy Wardley. All Rights Reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<Template::Plugin>

=cut

# Local Variables:
# mode: perl
# perl-indent-level: 4
# indent-tabs-mode: nil
# End:
#
# vim: expandtab shiftwidth=4:
