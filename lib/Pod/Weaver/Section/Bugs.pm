package Pod::Weaver::Section::Bugs;
use Moose;
use Text::Wrap ();
with 'Pod::Weaver::Role::Section';
# ABSTRACT: a section for bugtracker info

use Moose::Autobox;

=head1 OVERVIEW

This section plugin will produce a hunk of Pod giving bug reporting
information for the document, like this:

  =head1 BUGS

  Please report any bugs or feature requests on the bugtracker website
  http://rt.cpan.org/Dist/Display.html?Queue=Pod-Weaver

  When submitting a bug or request, please include a test-file or a
  patch to an existing test-file that illustrates the bug or desired
  feature.

This plugin requires a C<distmeta> parameter containing a hash reference of
L<CPAN::Meta::Spec> distribution metadata and at least one of one of the
parameters C<web> or C<mailto> defined in C<< $meta->{resources}{bugtracker} >>.

=cut

sub weave_section {
  my ($self, $document, $input) = @_;

  return unless exists $input->{distmeta}{resources}{bugtracker};
  my $bugtracker = $input->{distmeta}{resources}{bugtracker};
  my ($web,$mailto) = @{$bugtracker}{qw/web mailto/};
  return unless defined $web || defined $mailto;

  my $text = "Please report any bugs or feature requests ";

  if (defined $web) {
    $text .= "on the bugtracker website $web";
    $text .= defined $mailto ? " or " : "\n";
  }

  if (defined $mailto) {
    $text .= "by email to $mailto\.\n";
  }

  $text = Text::Wrap::wrap(q{}, q{}, $text);

  $text .= <<'HERE';

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.
HERE

  $document->children->push(
    Pod::Elemental::Element::Nested->new({
      command  => 'head1',
      content  => 'BUGS',
      children => [
        Pod::Elemental::Element::Pod5::Ordinary->new({ content => $text }),
      ],
    }),
  );
}

no Moose;
1;
