package Pod::Weaver::Weaver::Abstract;
use Moose;
with 'Pod::Weaver::Role::Weaver';

sub weave {
  my ($self) = @_;

  my $pkg_node = $self->weaver->perl->find_first('PPI::Statement::Package');

  Carp::croak "couldn't find package declaration in document" unless $pkg_node;

  my $package = $pkg_node->namespace;

  #unless (_h1(NAME => @pod)) {
  #  $self->log("couldn't find abstract in $arg->{filename}")
  #    unless my ($abstract) = $podless_doc_str =~ /^\s*#+\s*ABSTRACT:\s*(.+)$/m;

  #  my $name = $package;
  #  $name .= " - $abstract" if $abstract;

  #  unshift @pod, (
  #    { type => 'command', command => 'head1', content => "NAME\n"  },
  #    { type => 'text',                        content => "$name\n" },
  #  );
  #}
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
