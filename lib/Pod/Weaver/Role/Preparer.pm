package Pod::Weaver::Role::Preparer;
use Moose::Role;
with 'Pod::Weaver::Role::Plugin';
# ABSTRACT: something that mucks about with the input before weaving begins

requires 'prepare_input';

no Moose::Role;
1;
