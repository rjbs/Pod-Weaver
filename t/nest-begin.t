use strict;
use warnings;
use Test::More tests => 1;
use Test::Deep;
use Pod::Weaver::Parser::Nesting;

my $chunks = Pod::Weaver::Parser::Nesting->read_file('t/eg/nested-begin.pod');

my $want = [
  {
    cmd('head1'),
    content  => "DESCRIPTION\n",
    children => [
      { txt("Foo.\n") },
      {
        cmd('begin'),
        content  => "outer\n",
        children => [
          {
            cmd('begin'),
            content  => "inner\n",
            children => [
              {
                cmd('head1'),
                content  => "Inner!\n",
                children => [
                  {
                    cmd('over'),
                    content  => "\n",
                    children => [ { cmd('item'), content => "* one\n" } ],
                  },
                  {
                    cmd('begin'),
                    content => "inner\n",
                    children => [ { cmd('head1'), content => "Another!\n" } ],
                  },
                  {
                    cmd('head2'),
                    content => "Welcome to my Second Head\n",
                  },
                ],
              },
            ],
          },
          {
            cmd('head3'),
            content => "Finalizing\n",
          },
        ],
      },
      { txt("Baz.\n") },
    ],
  },
];

cmp_deeply(
  [ map {$_->as_hash} @$chunks ],
  $want,
  'nested =begins are not a problem'
);

sub cmd { return(type => 'command', command => $_[0]) }
sub txt { return(type => 'text',    content => $_[0]) }
