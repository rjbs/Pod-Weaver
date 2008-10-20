use strict;
use warnings;
use Test::More tests => 1;
use Test::Deep;
use Pod::Weaver::Parser::Simple;

my $chunks = Pod::Weaver::Parser::Simple->read_file('t/eg/Simple.pm');
my $want = [
  { type => 'command',  command => 'head1', content => "DESCRIPTION\n" },
  { type => 'text',     content => re(qr{^This is .+ that\?\n})     },
  { type => 'command',  command => 'synopsis', content => "\n"      },
  { type => 'verbatim', content => re(qr{^  use Test.+;$})          },
  { type => 'command',  command => 'head2', content => "Free Radical\n" },
  { type => 'command',  command => 'head3', content => "Subsumed Radical\n" },
  { type => 'command',  command => 'over',  content => "4\n" },
  { type => 'command',  command => 'item',  content => re(qr{^\* nom.+st\n}) },
  { type => 'command',  command => 'back',  content => "\n" },
  { type => 'command',  command => 'method',  content => "none\n"      },
  { type => 'text',     content => "Nope, there are no methods.\n",    },
  { type => 'command',  command => 'attr',    content => "also_none\n" },
  { type => 'text',     content => "None of these, either.\n"          },
  { type => 'command',  command => 'method',  content => "i_lied\n"    },
  { type => 'text',     content => "Ha!  Gotcha!\n"                    },
  { type => 'command',  command => 'cut',     content => "\n"          },
];

cmp_deeply(
  [ map {$_->as_hash} @$chunks ],
  $want,
  "we get the right chunky content we wanted",
);
