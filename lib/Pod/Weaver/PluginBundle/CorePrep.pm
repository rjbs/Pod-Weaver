use strict;
use warnings;
package Pod::Weaver::PluginBundle::CorePrep;
# ABSTRACT: a bundle for the most commonly-needed prep work for a pod document

# BEGIN BOILERPLATE
use v5.20.0;
use warnings;
use utf8;
no feature 'switch';
use experimental qw(postderef postderef_qq); # This experiment gets mainlined.
# END BOILERPLATE

use Pod::Weaver::Plugin::H1Nester;

sub mvp_bundle_config {
  return (
    [ '@CorePrep/EnsurePod5', 'Pod::Weaver::Plugin::EnsurePod5', {} ],
    # dialects should run here
    [ '@CorePrep/H1Nester',   'Pod::Weaver::Plugin::H1Nester',   {} ],
  );
}

1;
