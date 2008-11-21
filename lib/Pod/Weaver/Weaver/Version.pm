package Pod::Weaver::Weaver::Version;
use Moose;
with 'Pod::Weaver::Role::Weaver';
# ABSTRACT: add a VERSION pod section to your Perl module

use Moose::Autobox;

sub weave {
  my ($self, $arg) = @_;
  return unless $arg->{version};

  $self->weaver->output_pod->children->push(
    Pod::Elemental::Element::Command->new({
      type     => 'command',
      command  => 'head1',
      content  => 'VERSION',
      children => [
        Pod::Elemental::Element::Text->new({
          type    => 'text',
          content => sprintf('version %s', $arg->{version}),
        }),
      ],
    }),
  );
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
