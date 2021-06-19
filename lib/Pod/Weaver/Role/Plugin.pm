package Pod::Weaver::Role::Plugin;
# ABSTRACT: a Pod::Weaver plugin

use Moose::Role;

# BEGIN BOILERPLATE
use v5.20.0;
use warnings;
use utf8;
no feature 'switch';
use experimental qw(postderef postderef_qq); # This experiment gets mainlined.
# END BOILERPLATE

use Params::Util qw(_HASHLIKE);

use namespace::autoclean;

=head1 IMPLEMENTING

This is the most basic role that all plugins must perform.

=attr plugin_name

This name must be unique among all other plugins loaded into a weaver.  In
general, this will be set up by the configuration reader.

=cut

has plugin_name => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
);

=attr weaver

This is the Pod::Weaver object into which the plugin was loaded.  In general,
this will be set up when the weaver is instantiated from config.

=cut

has weaver => (
  is  => 'ro',
  isa => 'Pod::Weaver',
  required => 1,
  weak_ref => 1,
);

has logger => (
  is   => 'ro',
  lazy => 1,
  handles => [ qw(log log_debug log_fatal) ],
  default => sub {
    $_[0]->weaver->logger->proxy({
      proxy_prefix => '[' . $_[0]->plugin_name . '] ',
    });
  },
);

1;
