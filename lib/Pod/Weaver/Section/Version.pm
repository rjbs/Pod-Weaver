package Pod::Weaver::Section::Version;
use Moose;
with 'Pod::Weaver::Role::Section';
# ABSTRACT: add a VERSION pod section

use namespace::autoclean;

=head1 OVERVIEW

This section plugin will produce a hunk of Pod meant to indicate the version of
the document being viewed, like this:

  =head1 VERSION

  version 1.234

It will do nothing if there is no C<version> entry in the input.

=cut

use Moose::Autobox;

sub weave_section {
  my ($self, $document, $input) = @_;
  return unless $input->{version};

  $document->children->push(
    Pod::Elemental::Element::Nested->new({
      command  => 'head1',
      content  => 'VERSION',
      children => [
        Pod::Elemental::Element::Pod5::Ordinary->new({
          content => sprintf('version %s', $input->{version}),
        }),
      ],
    }),
  );
}

1;
