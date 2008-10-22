package Pod::Weaver::Weaver::Abstract;
use Moose;
with 'Pod::Weaver::Role::Weaver';
# ABSTRACT: add a NAME section with abstract (for your Perl module)

use Moose::Autobox;

sub weave {
  my ($self, $arg) = @_;

  my $pkg_node = $self->weaver->ppi_doc->find_first('PPI::Statement::Package');

  Carp::croak
    sprintf "couldn't find package declaration in %s", $arg->{filename}
    unless $pkg_node;

  my $package = $pkg_node->namespace;

  $self->log([ "couldn't find abstract in %s", $arg->{filename} ])
     unless my ($abstract) = $self->weaver->ppi_doc->serialize =~ /^\s*#+\s*ABSTRACT:\s*(.+)$/m;

  my $name = $package;
  $name .= " - $abstract" if $abstract;

  $self->weaver->output_pod->push(
    Pod::Elemental::Element::Command->new({
      type     => 'command',
      command  => 'head1',
      content  => 'NAME',
      children => [
        Pod::Elemental::Element::Text->new({
          type    => 'text',
          content => $name,
        }),
      ],
    }),
  );
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
