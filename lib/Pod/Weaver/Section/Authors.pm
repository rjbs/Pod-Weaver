package Pod::Weaver::Section::Authors;
# ABSTRACT: a section listing authors

use Moose;
with 'Pod::Weaver::Role::Section';

use Moose::Autobox;

use Pod::Elemental::Element::Nested;
use Pod::Elemental::Element::Pod5::Verbatim;

=head1 OVERVIEW

This section adds a listing of the documents authors.  It expects a C<authors>
input parameter to be an arrayref of strings.  If no C<authors> parameter is
given, it will do nothing.  Otherwise, it produces a hunk like this:

  =head1 AUTHORS

    Author One <a1@example.com>
    Author Two <a2@example.com>

=cut

sub weave_section {
  my ($self, $document, $input) = @_;

  return unless $input->{authors};

  my $multiple_authors = $input->{authors}->length > 1;

  my $name = $multiple_authors ? 'AUTHORS' : 'AUTHOR';
  my $authors = $input->{authors}->map(sub {
    Pod::Elemental::Element::Pod5::Ordinary->new({
      content => $_,
    }),
  });

  $authors = [
    Pod::Elemental::Element::Pod5::Command->new({
      command => 'over', content => '4',
    }),
    $authors->map(sub {
      Pod::Elemental::Element::Pod5::Command->new({
        command => 'item', content => '*',
      }),
      $_,
    })->flatten,
    Pod::Elemental::Element::Pod5::Command->new({
      command => 'back', content => '',
    }),
  ] if $multiple_authors;

  $document->children->push(
    Pod::Elemental::Element::Nested->new({
      type     => 'command',
      command  => 'head1',
      content  => $name,
      children => $authors,
    }),
  );
}

__PACKAGE__->meta->make_immutable;
1;
