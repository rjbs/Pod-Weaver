package Pod::Weaver::Config::Finder;

use Moose;
extends 'Config::MVP::Reader::Finder';
with 'Pod::Weaver::Config';
# ABSTRACT: the reader for weaver.ini files

sub default_search_path {
  return qw(Pod::Weaver::Config Config::MVP::Reader);
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
