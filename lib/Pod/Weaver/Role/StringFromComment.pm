package Pod::Weaver::Role::StringFromComment;
# ABSTRACT: Extract a string from a specially formatted comment

use Moose::Role;

# BEGIN BOILERPLATE
use v5.20.0;
use warnings;
use utf8;
no feature 'switch';
use experimental qw(postderef postderef_qq); # This experiment gets mainlined.
# END BOILERPLATE

use namespace::autoclean;

=head1 OVERVIEW

This role assists L<Pod::Weaver sections|Pod::Weaver::Role::Section> by
allowing them to pull strings from the source comments formatted like:

    # KEYNAME: Some string...

This is probably the most familiar to people using lines like the following to
allow the L<Name section|Pod::Weaver::Section::Name> to determine a module's
abstract:

    # ABSTRACT: Provides the HypnoToad with mind-control powers

It will extract these strings by inspecting the C<ppi_document> which
must be given.

=head1 PRIVATE METHODS

This role supplies only methods meant to be used internally by its consumer.

=head2 _extract_comment_content($ppi_doc, $key)

Given a key, try to find a comment matching C<# $key:> in the C<$ppi_document>
and return everything but the prefix.

e.g., given a document with a comment in it of the form:

    # ABSTRACT: Yada yada...

...and this is called...

    $self->_extract_comment_content($ppi, 'ABSTRACT')

...it returns to us:

    Yada yada...

=cut

sub _extract_comment_content {
  my ($self, $ppi_document, $key) = @_;

  my $regex = qr/^\s*#+\s*$key:\s*(.+)$/m;

  my $content;
  my $finder = sub {
    my $node = $_[1];
    return 0 unless $node->isa('PPI::Token::Comment');
    if ( $node->content =~ $regex ) {
      $content = $1;
      return 1;
    }
    return 0;
  };

  $ppi_document->find_first($finder);

  return $content;
}

1;
