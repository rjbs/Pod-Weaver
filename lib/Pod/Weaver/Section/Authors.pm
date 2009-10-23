package Pod::Weaver::Section::Authors;
use Moose;
with 'Pod::Weaver::Role::Section';
# ABSTRACT: a section listing authors

use Moose::Autobox;

use Pod::Elemental::Element::Nested;
use Pod::Elemental::Element::Pod5::Verbatim;

sub weave_section {
  my ($self, $document, $input) = @_;

  return unless $input->{authors};

  my $name = $input->{authors}->length > 1 ? 'AUTHORS' : 'AUTHOR';
  my $str  = $input->{authors}->join("\n");

  $str =~ s{^}{  }mg;

  $document->children->push(
    Pod::Elemental::Element::Nested->new({
      type     => 'command',
      command  => 'head1',
      content  => $name,
      children => [
        Pod::Elemental::Element::Pod5::Verbatim->new({ content => $str }),
      ],
    }),
  );
}

no Moose;
1;
