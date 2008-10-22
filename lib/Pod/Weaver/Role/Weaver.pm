package Pod::Weaver::Role::Weaver;
use Moose::Role;
with 'Pod::Weaver::Role::Plugin';

requires 'weave';

no Moose::Role;
1;
