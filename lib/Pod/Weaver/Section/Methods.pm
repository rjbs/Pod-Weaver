package Pod::Weaver::Plugin::Methods;
use Moose;
with 'Pod::Weaver::Role::Plugin';


#  my (@methods, $in_method);
#
#  $self->_regroup($_->[0] => $_->[1] => \@pod)
#    for ( [ attr => 'ATTRIBUTES' ], [ method => 'METHODS' ] );

__PACKAGE__->meta->make_immutable;
no Moose;
1;
