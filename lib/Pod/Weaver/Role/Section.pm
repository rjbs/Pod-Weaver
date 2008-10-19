package Pod::Weaver::Role::Section;
use Moose::Role;
with 'Pod::Weaver::Role::Plugin';

requires 'weave_section';

no Moose::Role;
1;
