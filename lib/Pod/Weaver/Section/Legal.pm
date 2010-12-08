package Pod::Weaver::Section::Legal;
use Moose;
with 'Pod::Weaver::Role::Section';
# ABSTRACT: a section for the copyright and license

use Moose::Autobox;

=head1 OVERVIEW

This section plugin will produce a hunk of Pod giving the copyright and license
information for the document, like this:

  =head1 COPYRIGHT AND LICENSE

  This document is copyright (C) 1991, Ricardo Signes.

  This document is available under the blah blah blah.

This plugin will do nothing if no C<license> input parameter is available.  The
C<license> is expected to be a L<Software::License> object.

If a L<Dist::Zilla> object is provided and the distribution contains a F<LICENSE>
file, an extra line of text will be added telling users to check the file for the
full text of the license.

=cut

sub weave_section {
  my ($self, $document, $input) = @_;

  return unless $input->{license};

  my $notice = $input->{license}->notice;
  chomp $notice;

  if ( $input->{zilla} ) {
    # TODO dzil docs claim that the file representation might change...
    foreach my $f ( @{ $input->{zilla}->files } ) {
      if ( $f->name eq 'LICENSE' ) {
        $notice .= "\n\nThe full text of the license can be found";
        $notice .= " in the LICENSE file included with this distribution.";
        last;
      }
    }
  }

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
