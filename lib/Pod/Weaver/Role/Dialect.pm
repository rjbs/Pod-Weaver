package Pod::Weaver::Role::Dialect;
# ABSTRACT: something that translates Pod subdialects to standard Pod5

use Moose::Role;
with 'Pod::Weaver::Role::Plugin';

use namespace::autoclean;

=head1 IMPLEMENTING

The Dialect role indicates that a plugin will be used to pre-process the input
Pod document before weaving begins.  The plugin must provide a
C<translate_dialect> method which will be called with the input hashref's
C<pod_document> entry.  It is expected to modify the document in place.

=cut

requires 'translate_dialect';

1;
