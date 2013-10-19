use strict;
use warnings;

use Test::More;
use Test::Differences;
use Moose::Autobox 0.10;

use PPI;

use Pod::Elemental;
use Pod::Elemental::Selectors -all;
use Pod::Elemental::Transformer::Pod5;
use Pod::Elemental::Transformer::Nester;

use Pod::Weaver;

my $in_pod   = do { local $/; open my $fh, '<:encoding(UTF-8)', 't/eg/encoding.in.pod'; <$fh> };
my $expected = do { local $/; open my $fh, '<:encoding(UTF-8)', 't/eg/encoding.out.pod'; <$fh> };
my $document = Pod::Elemental->read_string($in_pod);

my $perl_document = do { local $/; <DATA> };
my $ppi_document  = PPI::Document->new(\$perl_document);

my $weaver = Pod::Weaver->new_with_default_config;

require Software::License::Artistic_1_0;
my $woven = $weaver->weave_document({
  pod_document => $document,
  ppi_document => $ppi_document,

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

is($woven->children->length, 11, "we end up with a 11-paragraph document");

for (qw(1 2 4 5 6 7 9 10)) {
  my $para = $woven->children->[ $_ ];
  isa_ok($para, 'Pod::Elemental::Element::Nested', "element $_");
  is($para->command, 'head1', "... and is =head1");
}

is(
  $woven->children->[2]->children->[0]->content,
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

__DATA__

package Module::Name;
# ABSTRACT: abstract text

my $this = 'a test';
