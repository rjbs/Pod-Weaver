use strict;
use warnings;
package Pod::Weaver::PluginBundle::Default;
# ABSTRACT: a bundle for the most commonly-needed prep work for a pod document

=head1 OVERVIEW

This is the bundle used by default (specifically by Pod::Weaver's
C<new_with_default_config> method).  It may change over time, but should remain
fairly conservative and straightforward.

It is nearly equivalent to the following:

  [@CorePrep]
  
  [-SingleEncoding]

  [Name]
  [Version]

  [Region  / prelude]

  [Generic / SYNOPSIS]
  [Generic / DESCRIPTION]
  [Generic / OVERVIEW]

  [Collect / ATTRIBUTES]
  command = attr

  [Collect / EVENTS]
  command = event

  [Collect / METHODS]
  command = method

  [Collect / FUNCTIONS]
  command = func

  [Leftovers]

  [Region  / postlude]

  [Authors]
  [Legal]

=cut

use namespace::autoclean;

use Pod::Weaver::Config::Assembler;
sub _exp { Pod::Weaver::Config::Assembler->expand_package($_[0]) }

sub mvp_bundle_config {
  return (
    [ '@Default/CorePrep',        _exp('@CorePrep'), {} ],
    [ '@Default/SingleEncoding',  _exp('-SingleEncoding'), {} ],
    [ '@Default/Name',            _exp('Name'),      {} ],
    [ '@Default/Version',         _exp('Version'),   {} ],

    [ '@Default/prelude',   _exp('Region'),    { region_name => 'prelude'  } ],
    [ 'SYNOPSIS',           _exp('Generic'),   {} ],
    [ 'DESCRIPTION',        _exp('Generic'),   {} ],
    [ 'OVERVIEW',           _exp('Generic'),   {} ],

    [ 'ATTRIBUTES',         _exp('Collect'),   { command => 'attr'   } ],
    [ 'EVENTS',             _exp('Collect'),   { command => 'event'  } ],
    [ 'METHODS',            _exp('Collect'),   { command => 'method' } ],
    [ 'FUNCTIONS',          _exp('Collect'),   { command => 'func'   } ],

    [ '@Default/Leftovers', _exp('Leftovers'), {} ],

    [ '@Default/postlude',  _exp('Region'),    { region_name => 'postlude' } ],

    [ '@Default/Authors',   _exp('Authors'),   {} ],
    [ '@Default/Legal',     _exp('Legal'),     {} ],
  )
}

1;
