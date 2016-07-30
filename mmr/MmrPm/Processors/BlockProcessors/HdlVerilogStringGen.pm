package MmrPm::Processors::BlockProcessors::HdlVerilogStringGen;

use Moose;

=head

Module = MmrPm::Processors::BlockProcessors::HdlVerilogStringGen

This is the only file decision based on type should be taken. 

Current valid types

rc = Read only constant
ro = Read only wire
rw = RW register
wo = Write only register

=cut


sub retBusAssn {
  my ( $self, $sigRef ) = @_;
  my $str = "[";
  $str .= $sigRef->{width} + $sigRef->{offset} - 1;
  $str .= ":$sigRef->{offset}]";
  return $str;
}

sub buildRegResetValue {
  my ( $self, $topCfgRef, $sigRef, $signal, $addPrefix ) = @_;
  my $tmp = "";
  $tmp = sprintf( "%-*s", ( $topCfgRef->{work}{widths}{signal} ), $signal );
  $tmp .= " <= $sigRef->{width}'d$sigRef->{def}";
  return $tmp;
}

sub buildRegWriteValue {
  my ( $self, $topCfgRef, $sigRef, $signal, $addPrefix ) = @_;
  my $tmp = "";
  $tmp = sprintf( "%-*s", ( $topCfgRef->{work}{widths}{signal} ), $signal );
  $tmp .= " <= reg_bank_wr_data" . $self->retBusAssn($sigRef);
  return $tmp;
}

sub buildRegReadValue {
  my ( $self, $topCfgRef, $sigRef, $signal, $addPrefix ) = @_;
  my $tmp = "";
  $tmp = sprintf( "%-*s", ( $topCfgRef->{work}{widths}{bus} ), $self->retBusAssn($sigRef) );
  $tmp .= " = $signal";
  return $tmp;
}

sub buildWirePortDec {
  my ( $self, $topCfgRef, $sigRef, $signal, $addPrefix ) = @_;
  my $tmp = "wire ";
  my $work = ( $sigRef->{width} > 1 ) ? sprintf( "[%d:0]", ( $sigRef->{width} - 1 ) ) : "";
  $tmp .= sprintf( "%-*s",           ( $topCfgRef->{work}{widths}{bus} + 4 ), $work );
  $tmp .= sprintf( "$addPrefix%-*s", ( $topCfgRef->{work}{widths}{signal} ),  $signal );
  return $tmp;
}

sub buildInstanceConnection {
  my ( $self, $topCfgRef, $sigRef, $signal, $addPrefix ) = @_;
  my $tmp = ".";
  $tmp .= sprintf( "%-*s",           ( $topCfgRef->{work}{widths}{signal} ), $signal );
  $tmp .= "(";
  $tmp .= sprintf( "$addPrefix%-*s", ( $topCfgRef->{work}{widths}{signal} ), $signal );
  $tmp .= ")";
  return $tmp;
}

sub buildRegPortDec {
  my ( $self, $topCfgRef, $sigRef, $signal, $addPrefix ) = @_;
  my $tmp = "reg  ";
  my $work = ( $sigRef->{width} > 1 ) ? sprintf( "[%d:0]", ( $sigRef->{width} - 1 ) ) : "";
  $tmp .= sprintf( "%-*s", ( $topCfgRef->{work}{widths}{bus} + 4 ), $work );
  $tmp .= sprintf( "%-*s", ( $topCfgRef->{work}{widths}{signal} ),  $signal );

  # This should be conditional, not sure valid is ASIC tools?
  $tmp .= " = $sigRef->{width}'d$sigRef->{def}";

  return $tmp;
}


1;
