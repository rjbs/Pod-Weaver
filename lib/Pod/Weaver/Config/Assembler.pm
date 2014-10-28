package Pod::Weaver::Config::Assembler;
# ABSTRACT: Pod::Weaver-specific subclass of Config::MVP::Assembler

use Moose;
extends 'Config::MVP::Assembler';
with 'Config::MVP::Assembler::WithBundles';

use String::RewritePrefix;

use namespace::autoclean;

sub expand_package {
  my $str = $_[1];

  return scalar String::RewritePrefix->rewrite(
    {
      ''  => 'Pod::Weaver::Section::',
      '-' => 'Pod::Weaver::Plugin::',
      '@' => 'Pod::Weaver::PluginBundle::',
      '=' => '',
    },
    $str,
  );
}

__PACKAGE__->meta->make_immutable;
1;
