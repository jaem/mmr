package MmrPm::Processors::BlockProcessors::RegAccessDecisions;

use Moose;

=head

Module = MmrPm::Processors::BlockProcessors::RegAccessDecisions

This is the only file decision based on type should be taken. 

Current valid types

rc = Read only constant
ro = Read only wire
rw = RW register
wo = Write only register

=cut

sub isSignalReadable {
  my ( $self, $type ) = @_;
  return ( $self->isSignalInput($type) | ( $type =~ m/^(?:rw)$/ ) );
}

sub isSignalInput {
  my ( $self, $type ) = @_;
  return ( $type =~ m/^(?:ro|rc)$/ );
}

sub isSignalOutput {
  my ( $self, $type ) = @_;
  return ( $type =~ m/^(?:rw|wo)$/ );
}

#sub typeRequiresRegRwStrobes {
#  my ( $self, $type ) = @_;
#  return ( $type =~ m/^(?:reg_sync_v)$/ );
#}


=head
This needs to deal with 64 correctly.....really address width is a top
level setting......however there could be convertors in the way so 
prob needs to be a block setting. If unspecified maps to top cfg.
This should be done in check section
=cut

sub retCaseAddr {
  my ( $self, $cfgRef, $sigRef ) = @_;
  return $sigRef->{addr} >> 2;
}

1;
