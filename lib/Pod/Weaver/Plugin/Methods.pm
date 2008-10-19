  my (@methods, $in_method);

  $self->_regroup($_->[0] => $_->[1] => \@pod)
    for ( [ attr => 'ATTRIBUTES' ], [ method => 'METHODS' ] );
