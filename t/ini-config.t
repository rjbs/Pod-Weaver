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

my $perl_document = do { local $/; <DATA> };
my $ppi_document  = PPI::Document->new(\$perl_document);

my $weaver = Pod::Weaver->new_from_config({ root => 't/eg' });

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

__DATA__

package Module::Name;
# ABSTRACT: abstract text

my $this = 'a test';
