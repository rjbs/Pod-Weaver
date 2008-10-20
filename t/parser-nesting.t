use strict;
use warnings;
use Test::More tests => 1;
use Test::Deep;
use Pod::Weaver::Parser::Nesting;

my $chunks = Pod::Weaver::Parser::Nesting->read_file('t/eg/Simple.pm');
my $want = [
  {
    cmd('head1'),
    content  => "DESCRIPTION\n",
    children => [ { txt( re(qr{^This is .+ that\?\n}) ) } ],
  },

  {
    cmd('synopsis'),
    content  => "\n",
    children => [ { type => 'verbatim', content => re(qr{^  use Test.+;$}) } ]
  },

  {
    cmd('head2'),
    content => "Free Radical\n",
    children => [
      {
        cmd('head3'),
        content => "Subsumed Radical\n",
        children => [
          {
            cmd('over'),
            content => "4\n",
            children => [
              { cmd('item'), content => re(qr{^\* nom.+st\n}) },
              { cmd('back'), content => "\n" },
  ], }, ], } ], },

  {
    cmd('method'),
    content => "none\n",
    children => [ { txt("Nope, there are no methods.\n") } ],
  },

  {
    cmd('attr'),
    content  => "also_none\n",
    children => [ { txt("None of these, either.\n") } ],
  },

  {
    cmd('method'),
    content  => "i_lied\n",
    children => [ { txt("Ha!  Gotcha!\n") } ],
  },
];

cmp_deeply(
  [ map {$_->as_hash} @$chunks ],
  $want,
  "we get the right chunky content we wanted",
);

# diag $_->as_string for @$chunks;

sub cmd { return(type => 'command', command => $_[0]) }
sub txt { return(type => 'text',    content => $_[0]) }
