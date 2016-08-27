package MmrPm::Processors::BlockProcessors::CheckRegKeyValuesAreValid;

use Moose;

=head

Module = MmrPm::Processors::BlockProcessors::CheckRegKeyValuesAreValid


=cut

sub checkAllSignalKeysExist {
  my ( $self, $sigName, $sigRef, $block ) = @_;
  $self->addKeyValueThatsOptionalIfNotExists( $sigRef, "enable", 1 );
  $self->addKeyValueThatsOptionalIfNotExists( $sigRef, "clk",    '' );
  $self->addKeyValueThatsOptionalIfNotExists( $sigRef, "doc",    '' );

  $self->checkThatARequiredKeyExists( $sigRef, "width", $sigName, $block );
  $self->checkThatAKeyValueMatchesRegex( $sigRef, "width", $sigName, $block, '^[0-9]+$', 'must be an integer value ' );
  $self->checkThatAKeyValueMatchesRegex( $sigRef, "width", $sigName, $block, '^[1-9]+$', 'cannot be zero ' );

  $self->checkThatARequiredKeyExists( $sigRef, "def", $sigName, $block );
  $self->checkThatAKeyValueMatchesRegex( $sigRef, "def", $sigName, $block, '^[0-9]+$', 'must be an integer value ' );

  $self->checkThatARequiredKeyExists( $sigRef, "type",   $sigName, $block );
  $self->checkThatARequiredKeyExists( $sigRef, "doc",    $sigName, $block );
  $self->checkThatARequiredKeyExists( $sigRef, "addr",   $sigName, $block );
  $self->checkThatARequiredKeyExists( $sigRef, "offset", $sigName, $block );
  $self->checkThatARequiredKeyExists( $sigRef, "clk",    $sigName, $block );

  $self->checkThatARequiredKeyExists( $sigRef, "enable", $sigName, $block );
  $self->checkThatAKeyValueMatchesRegex( $sigRef, "enable", $sigName, $block, '^[01]+$', 'must be 0 or 1 ' );

}

sub addKeyValueThatsOptionalIfNotExists {
  my ( $self, $sigRef, $key, $value ) = @_;
  $sigRef->{$key} = $value if ( !exists $sigRef->{$key} );
}

sub checkThatARequiredKeyExists {
  my ( $self, $sigRef, $key, $sigName, $block ) = @_;
  if ( !exists $sigRef->{$key} ) {
    $self->pErrMess( $key, $sigName, $block, 'must have a value ' );
  }
}

sub checkThatAKeyValueMatchesRegex {
  my ( $self, $sigRef, $key, $sigName, $block, $regex, $comment ) = @_;
  if ( $sigRef->{$key} !~ m/$regex/ ) {
    $self->pErrMess( $key, $sigName, $block, $comment );
  }
}

sub pErrMess {
  my ( $self, $key, $sigName, $block, $comment ) = @_;
  print "CONFIG Error: $key ${comment}for signal $sigName in $block\n";
  exit();
}
1;
