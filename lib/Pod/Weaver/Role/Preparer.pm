package Pod::Weaver::Role::Preparer;
use Moose::Role;
with 'Pod::Weaver::Role::Plugin';
# ABSTRACT: something that mucks about with the input before weaving begins

=head1 IMPLEMENTING

The Preparer role indicates that a plugin will be used to pre-process the input
hashref before weaving begins.  The plugin must provide a C<prepare_input>
method which will be called with the input hashref.  It is expected to modify
the input in place.

=cut

requires 'prepare_input';

no Moose::Role;
1;
