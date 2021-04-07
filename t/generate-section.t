#!perl
use strict;
use warnings;
use utf8;

use Test::More;

use Pod::Elemental;
use Pod::Weaver;
use Pod::Weaver::Config::Assembler;
use PPI;

sub make_weaver {
  my ($config) = @_;

  my $assembler = Pod::Weaver::Config::Assembler->new;

  my $root = $assembler->section_class->new({ name => '_' });
  $assembler->sequence->add_section($root);

  $assembler->change_section('GenerateSection');

  # XXX This is junky. -- rjbs, 2021-04-05
  for my $key (keys %$config) {
    if ($key eq 'text') {
      my @lines = split /\n/, $config->{$key};
      $assembler->add_value($key => $_) for @lines;
    } else {
      $assembler->add_value($key => $config->{$key});
    }
  }

  $assembler->end_section;

  return Pod::Weaver->new_from_config_sequence($assembler->sequence, {});
}

sub weave_ok {
  my ($section_config, $extra_input, $expect) = @_;

  my $in_pod   = q{};
  my $document = Pod::Elemental->read_string($in_pod); # wants octets

  my $ppi_document  = PPI::Document->new(\"");

  my $weaver = make_weaver($section_config);

  my $woven = $weaver->weave_document({
    pod_document => $document,
    ppi_document => $ppi_document,

    %$extra_input,
  });

  my $pod_string = $woven->as_pod_string;

  local $Test::Builder::Level = $Test::Builder::Level + 1;

  if (ref $expect) {
    return like($pod_string, $expect, "woven document is okay");
  }

  $pod_string =~ s/\A=pod\v+//;

  return is(
    $pod_string,
    $expect,
    "woven document contains expected substring",
  );
}

weave_ok(
  { title => 'Header Title' },
  {},
  "=head1 Header Title\n\n=cut\n",
);

weave_ok(
  {
    title => 'Whatever',
    text  => 'This is package {{$name}} v{{$version}}',
  },
  {
    zilla    => 1, # to trigger zilla-like operation
    distmeta => { name => "Foo", version => "1.2.3" },
  },
  "=head1 Whatever\n\nThis is package Foo v1.2.3\n\n=cut\n",
);

{
  my $template = <<'END';
Name {{$name}}
v{{$version}}
Homepage {{$homepage}}
repo web {{$repository_web}}
repo url {{$repository_url}}
bugtracker url {{$bugtracker_web}}
bugtracker email {{$bugtracker_email}}
END

  my $expect = <<'END';
=head1 Gorp

Name Foo-Bar
v0.010
Homepage https://foo-bar.xyz/
repo web https://hg.xyz.com/hgweb/pro
repo url https://there.com/dude/project
bugtracker url https://foo-bar.xyz/bugs/
bugtracker email bug-project@foo-bar-example

=cut
END

  weave_ok(
    {
      title => 'Gorp',
      text  => $template,
    },
    {
      zilla    => 1, # to trigger zilla-like operation
      distmeta => {
        name    => 'Foo-Bar',
        version => '0.010',
        resources => {
          homepage   => 'https://foo-bar.xyz/',
          repository => {
            url => 'https://there.com/dude/project',
            web => 'https://hg.xyz.com/hgweb/pro',
          },
          bugtracker => {
            web     => 'https://foo-bar.xyz/bugs/',
            mailto  => 'bug-project@foo-bar-example',
          },
        },
      },
    },
    $expect,
  );
}

weave_ok(
  {
    title => 'Whatever',
    text  => 'This is package {{$name}} v{{$version}}',
    is_template => 0,
  },
  {
    zilla    => 1, # to trigger zilla-like operation
    distmeta => { name => "Foo", version => "1.2.3" },
  },
  "=head1 Whatever\n\nThis is package {{\$name}} v{{\$version}}\n\n=cut\n",
);

weave_ok(
  {
    head  => 2,
    title => 'Whatever',
    text  => 'Xyz',
  },
  {},
  "=head2 Whatever\n\nXyz\n\n=cut\n",
);

weave_ok(
  {
    head  => 0,
    title => 'Whatever',
    text  => 'Xyz',
  },
  {},
  "Xyz\n\n=cut\n",
);

weave_ok(
  {
    title => 'Foo',
    text  => "This\n\n\nrocks.",
  },
  {},
  "=head1 Foo\n\nThis\n\n\nrocks.\n\n=cut\n",
);

done_testing;
