package Pod::Weaver::Role::Finalizer;
use Moose::Role;
with 'Pod::Weaver::Role::Plugin';
# ABSTRACT: something that goes back and finishes up after main weaving is over

requires 'finalize_document';

no Moose::Role;
1;
