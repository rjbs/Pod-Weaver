package Pod::Weaver::Section::Legal;
use Moose;
with 'Pod::Weaver::Role::Section';
# ABSTRACT: a section for the copyright and license

use Moose::Autobox;

sub weave_section {
  my ($self, $document, $input) = @_;

  return unless $input->{license};

  my $notice = $input->{license}->notice;
  chomp $notice;

  $document->children->push(
    Pod::Elemental::Element::Nested->new({
      command  => 'head1',
      content  => 'COPYRIGHT AND LICENSE',
      children => [
        Pod::Elemental::Element::Pod5::Ordinary->new({ content => $notice }),
      ],
    }),
  );
}

no Moose;
1;
