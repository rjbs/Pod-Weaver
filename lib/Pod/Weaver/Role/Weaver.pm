package Pod::Weaver::Role::Weaver;
use Moose::Role;
with 'Pod::Weaver::Role::Plugin';
# ABSTRACT: a weaver plugin

requires 'weave';

no Moose::Role;
1;
