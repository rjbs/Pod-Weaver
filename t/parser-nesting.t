use strict;
use warnings;
use Test::More tests => 1;
use Test::Deep;
use Pod::Weaver::Parser::Nesting;

my $chunks = Pod::Weaver::Parser::Nesting->read_file('t/eg/Simple.pm');
my $want = [
  {
    type     => 'command',
    command  => 'head1',
    content  => "DESCRIPTION\n",
    children => [
      { type => 'text', content => re(qr{^This is .+ that\?\n}) },
    ],
  },

  {
    type     => 'command',
    command  => 'synopsis',
    content  => "\n",
    children => [
      { type => 'verbatim', content => re(qr{^  use Test.+;$}) },
    ]
  },

  {
    type => 'command',
    command => 'head2',
    content => "Free Radical\n",
    children => [
      {
        type => 'command',
        command => 'head3',
        content => "Subsumed Radical\n",
        children => [
          {
            type => 'command',
            command => 'over',
            content => "4\n",
            children => [
              {
                type => 'command',
                command => 'item',
                content => re(qr{^\* nom.+st\n})
              },
              {
                type => 'command',
                command => 'back',
                content => "\n"
              },
            ],
          },
        ],
      }
    ],
  },

  {
    type => 'command',
    command => 'method',
    content => "none\n",
    children => [
      {
        type    => 'text',
        content => "Nope, there are no methods.\n",
      },
    ],
  },

  {
    type     => 'command',
    command  => 'attr',
    content  => "also_none\n",
    children => [
      { type => 'text',     content => "None of these, either.\n"          },
    ],
  },

  {
    type => 'command',
    command => 'method',
    content => "i_lied\n",
    children => [
      { type => 'text',     content => "Ha!  Gotcha!\n"                    },
    ],
  },

  { type => 'command',  command => 'cut',     content => "\n"          },
];

cmp_deeply(
  [ map {$_->as_hash} @$chunks ],
  $want,
  "we get the right chunky content we wanted",
);
