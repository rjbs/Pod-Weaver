use strict;
use warnings;

use Test::More;
use Test::Differences;

use PPI;

use Pod::Elemental;
use Pod::Elemental::Selectors -all;
use Pod::Elemental::Transformer::Pod5;
use Pod::Elemental::Transformer::Nester;

use Pod::Weaver;

my $in_pod   = do { local $/; open my $fh, '<:raw:bytes', 't/eg/ini-config.in.pod'; <$fh> };
my $expected = do { local $/; open my $fh, '<:encoding(UTF-8)', 't/eg/ini-config.out.pod'; <$fh> };
my $document = Pod::Elemental->read_string($in_pod);

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
# 0      =encoding UTF-8
# 1      =head1 NAME
#   0      Pod5::Ordinary <Module::Name - abstract text>
# 2      =head1 VERSION
#   0      Pod5::Ordinary <version 1.012078>
# 3      Pod5::Ordinary <Please pay clos…the following.>
# 4      =head1 SYNOPSIS
#   0      Pod5::Ordinary <This should pro…oved up front.>
# 5      =head1 DESCRIPTION
#   0      Pod5::Ordinary <This is a simpl…g Pod::Weaver.>
#   1      Pod5::Ordinary <It does not do very much.>
# 6      =head1 ATTRIBUTES
#   0      Pod5::Ordinary <This is a heade…tributes list.>
#   1      =head2 is_awesome
#     0      Pod5::Ordinary <(This is true by default.)>
# 7      =head1 METHODS
# 8      =head2 Class Methods
#   0      =head3 do_something
#     0      Pod5::Ordinary <Does something … class method.>
# 9      =head1 BE FOREWARNED
#   0      Pod5::Ordinary <This is not supported:>
#   1      Pod5::Verbatim <  much at all>
#   2      Pod5::Ordinary <Happy hacking!>
# 10     =head3 This is a leftover
# 11     Pod5::Ordinary <Shouldn't be ne… do_something.>
# 12     Pod5::Ordinary <Thank you for your attention.>
# 13     =head1 AUTHORS
#   0      Pod5::Verbatim <  Ricardo Signe…rs@orbit.tash>>
# 14     =head1 COPYRIGHT AND LICENSE
#   0      Pod5::Ordinary <This software i…ic License 1.0>

is(@{ $woven->children }, 15, "we end up with a 15-paragraph document");

for (qw(1 2 4 5 6 9 13 14)) {
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
