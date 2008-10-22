package Pod::Weaver::Weaver::Version;
use Moose;
with 'Pod::Weaver::Role::Weaver';

use Moose::Autobox;

sub weave {
  my ($self) = @_;
#  if ($arg->{version} and not _h1(VERSION => @pod)) {

  $self->weaver->output_pod->push(
    Pod::Elemental::Element::Command->new({
      type     => 'command',
      command  => 'head1',
      content  => 'VERSION',
      children => [
        Pod::Elemental::Element::Text->new({
          type    => 'text',
          content => sprintf('version %s', 1),
        }),
      ],
    }),
  );
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
