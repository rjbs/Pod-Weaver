package Pod::Weaver::Weaver::License;
use Moose;
with 'Pod::Weaver::Role::Weaver';
# ABSTRACT: add a license notice

use Moose::Autobox;

sub weave {
  my ($self, $arg) = @_;

  return unless $arg->{license};

  my $notice = $arg->{license}->notice;
  chomp $notice;

  $self->weaver->output_pod->children->push(
    Pod::Elemental::Element::Command->new({
      type     => 'command',
      command  => 'head1',
      content  => 'COPYRIGHT AND LICENSE',
      children => [
        Pod::Elemental::Element::Text->new({
          type    => 'text',
          content => $notice,
        }),
      ],
    }),
  );
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
