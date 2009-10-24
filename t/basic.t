use strict;
use warnings;

use Test::More;
use Test::Differences;
use Moose::Autobox 0.10;

use Pod::Elemental;
use Pod::Elemental::Selectors -all;
use Pod::Elemental::Transformer::Pod5;
use Pod::Elemental::Transformer::Nester;

use Pod::Weaver;

my $in_pod   = do { local $/; open my $fh, '<', 't/eg/basic.in.pod'; <$fh> };
my $expected = do { local $/; open my $fh, '<', 't/eg/basic.out.pod'; <$fh> };
my $document = Pod::Elemental->read_string($in_pod);

Pod::Elemental::Transformer::Pod5->new->transform_node($document);
Pod::Elemental::Transformer::Nester->new({
  top_selector => s_command('head1'),
  content_selectors => [
    s_command([ qw(head2 head3 head4 over item back) ]),
    s_flat,
  ],
})->transform_node($document);

my $weaver = Pod::Weaver->new;

{
  use Pod::Weaver::Section::Name;
  my $name = Pod::Weaver::Section::Name->new({
    weaver      => $weaver,
    plugin_name => 'Name',
  });

  $weaver->plugins->push($name);
}

{
  use Pod::Weaver::Section::Version;
  my $version = Pod::Weaver::Section::Version->new({
    weaver      => $weaver,
    plugin_name => 'Version',
  });

  $weaver->plugins->push($version);
}

{
  use Pod::Weaver::Section::Region;
  my $prelude = Pod::Weaver::Section::Region->new({
    weaver      => $weaver,
    plugin_name => 'prelude',
  });

  $weaver->plugins->push($prelude);
}

{
  use Pod::Weaver::Section::Generic;
  for my $section (qw(SYNOPSIS DESCRIPTION OVERVIEW)) {
    my $generic = Pod::Weaver::Section::Generic->new({
      weaver      => $weaver,
      plugin_name => $section,
    });

    $weaver->plugins->push($generic);
  }
}

{
  use Pod::Weaver::Section::Collect;
  for my $pair (
    [ qw(attr   ATTRIBUTES) ],
    [ qw(method METHODS   ) ],
  ) {
    my $collect = Pod::Weaver::Section::Collect->new({
      weaver      => $weaver,
      plugin_name => $pair->[1],
      command     => $pair->[0],
    });

    $weaver->plugins->push($collect);
  }
}


{
  use Pod::Weaver::Section::Leftovers;
  my $leftovers = Pod::Weaver::Section::Leftovers->new({
    weaver      => $weaver,
    plugin_name => 'Leftovers',
  });

  $weaver->plugins->push($leftovers);
}

{
  use Pod::Weaver::Section::Region;
  my $postlude = Pod::Weaver::Section::Region->new({
    weaver      => $weaver,
    plugin_name => 'postlude',
  });

  $weaver->plugins->push($postlude);
}

{
  use Pod::Weaver::Section::Authors;
  my $authors = Pod::Weaver::Section::Authors->new({
    weaver      => $weaver,
    plugin_name => 'Authors',
  });

  $weaver->plugins->push($authors);
}

{
  use Pod::Weaver::Section::Legal;
  my $legal = Pod::Weaver::Section::Legal->new({
    weaver      => $weaver,
    plugin_name => 'Legal',
  });

  $weaver->plugins->push($legal);
}

require Software::License::Artistic_1_0;
my $woven = $weaver->weave_document({
  document => $document,
  version  => '1.012078',
  authors  => [
    'Ricardo Signes <rjbs@example.com>',
    'Molly Millions <sshears@orbit.tash>',
  ],
  license  => Software::License::Artistic_1_0->new({
    holder => 'Ricardo Signes',
    year   => 1999,
  }),
});

#      Document
# 0      =head1 NAME
#   0      Pod5::Ordinary <Module::Name - abstract text>
# 1      =head1 VERSION
#   0      Pod5::Ordinary <version 1.012078>
# 2      Pod5::Ordinary <Please pay clos…the following.>
# 3      =head1 SYNOPSIS
#   0      Pod5::Ordinary <This should pro…oved up front.>
# 4      =head1 DESCRIPTION
#   0      Pod5::Ordinary <This is a simpl…g Pod::Weaver.>
#   1      Pod5::Ordinary <It does not do very much.>
# 5      =head1 ATTRIBUTES
#   0      =head2 is_awesome
#     0      Pod5::Ordinary <(This is true by default.)>
# 6      =head1 BE FOREWARNED
#   0      Pod5::Ordinary <This is not supported:>
#   1      Pod5::Verbatim <  much at all>
#   2      Pod5::Ordinary <Happy hacking!>
# 7      Pod5::Ordinary <Thank you for your attention.>
# 8      =head1 AUTHORS
#   0      Pod5::Verbatim <  Ricardo Signe…rs@orbit.tash>>
# 9      =head1 COPYRIGHT AND LICENSE
#   0      Pod5::Ordinary <This software i…ic License 1.0>

is($woven->children->length, 10, "we end up with a 10-paragraph document");

for (qw(0 1 3 4 5 6 8 9)) {
  my $para = $woven->children->[ $_ ];
  isa_ok($para, 'Pod::Elemental::Element::Nested', "element $_");
  is($para->command, 'head1', "... and is =head1");
}

is(
  $woven->children->[1]->children->[0]->content,
  'version 1.012078',
  "the version is in the version section",
);

# XXX: This test is extremely risky as things change upstream.
# -- rjbs, 2009-10-23
eq_or_diff(
  $woven->as_pod_string,
  $expected,
  "exactly the pod string we wanted after weaving!",
);

done_testing;
