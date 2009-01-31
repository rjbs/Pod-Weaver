package Pod::Weaver::Role::Plugin;
use Moose::Role;
# ABSTRACT: a Pod::Weaver plugin

has plugin_name => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
  init_arg => '=name',
);

has weaver => (
  is  => 'ro',
  isa => 'Pod::Weaver',
  required => 1,
  weak_ref => 1,
  handles  => [ qw(log) ],
);

no Moose::Role;
1;
