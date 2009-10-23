package Pod::Weaver::Role::Section;
use Moose::Role;
with 'Pod::Weaver::Role::Plugin';
# ABSTRACT: a plugin that will get a section into a woven document

requires 'weave_section';

no Moose::Role;
1;
