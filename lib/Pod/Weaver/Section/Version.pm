package Pod::Weaver::Section::Version;
use Moose;
with 'Pod::Weaver::Role::Section';
# ABSTRACT: add a VERSION pod section

use Moose::Autobox;

sub weave_section {
  my ($self, $document, $input) = @_;
  return unless $input->{version};

  $document->children->push(
    Pod::Elemental::Element::Nested->new({
      command  => 'head1',
      content  => 'VERSION',
      children => [
        Pod::Elemental::Element::Pod5:Ordinary->new({
          content => sprintf('version %s', $arg->{version}),
        }),
      ],
    }),
  );
}

no Moose;
1;
