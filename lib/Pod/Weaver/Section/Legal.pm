package Pod::Weaver::Section::Legal;
# ABSTRACT: a section for the copyright and license

use Moose;
with 'Pod::Weaver::Role::Section';

=head1 OVERVIEW

This section plugin will produce a hunk of Pod giving the copyright and license
information for the document, like this:

  =head1 COPYRIGHT AND LICENSE

  This document is copyright (C) 1991, Ricardo Signes.

  This document is available under the blah blah blah.

This plugin will do nothing if no C<license> input parameter is available.  The
C<license> is expected to be a L<Software::License> object.

=cut

=attr license_file

Specify the name of the license file and an extra line of text will be added
telling users to check the file for the full text of the license.

Defaults to none.

=attr header

The title of the header to be added.
(default: "COPYRIGHT AND LICENSE")

=cut

has header => (
  is      => 'ro',
  isa     => 'Str',
  default => 'COPYRIGHT AND LICENSE',
);

has license_file => (
  is => 'ro',
  isa => 'Str',
  predicate => '_has_license_file',
);

sub weave_section {
  my ($self, $document, $input) = @_;

  unless ($input->{license}) {
    $self->log_debug('no license specified, not adding a ' . $self->header . ' section');
    return;
 }

  my $notice = $input->{license}->notice;
  chomp $notice;

  if ( $self->_has_license_file ) {
    $notice .= "\n\nThe full text of the license can be found in the\nF<";
    $notice .= $self->license_file . "> file included with this distribution.";
  }

  $self->log_debug('adding ' . $self->header . ' section');

  push @{ $document->children },
    Pod::Elemental::Element::Nested->new({
      command  => 'head1',
      content  => $self->header,
      children => [
        Pod::Elemental::Element::Pod5::Ordinary->new({ content => $notice }),
      ],
    });
}

__PACKAGE__->meta->make_immutable;
1;
