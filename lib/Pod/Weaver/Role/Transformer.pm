package Pod::Weaver::Role::Transformer;
use Moose::Role;
with 'Pod::Weaver::Role::Plugin';
# ABSTRACT: something that restructures a Pod5 document

=head1 IMPLEMENTING

The Transformer role indicates that a plugin will be used to pre-process the input
hashref's Pod document before weaving begins.  The plugin must provide a
C<transform_document> method which will be called with the input Pod document.
It is expected to modify the input in place.

=cut

requires 'transform_document';

no Moose::Role;
1;
