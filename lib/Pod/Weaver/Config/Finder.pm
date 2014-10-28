package Pod::Weaver::Config::Finder;
# ABSTRACT: the reader for weaver.ini files

use Moose;
extends 'Config::MVP::Reader::Finder';
with 'Pod::Weaver::Config';

use namespace::autoclean;

sub default_search_path {
  return qw(Pod::Weaver::Config Config::MVP::Reader);
}

__PACKAGE__->meta->make_immutable;
1;
