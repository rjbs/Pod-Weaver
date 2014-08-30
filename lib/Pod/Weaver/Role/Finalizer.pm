package Pod::Weaver::Role::Finalizer;

use Moose::Role;
with 'Pod::Weaver::Role::Plugin';
# ABSTRACT: something that goes back and finishes up after main weaving is over

=head1 IMPLEMENTING

The Finalizer role indicates that a plugin will be used to post-process the
output document hashref after section weaving is completed.  The plugin must
provide a C<finalize_document> method which will be called as follows:

  $finalizer_plugin->finalize_document($document, \%input);

=cut

requires 'finalize_document';

no Moose::Role;
1;
