use strict;
use warnings;
use Test::More tests => 1;
use Test::Deep;
use Pod::Weaver::Parser::Nesting;

my $chunks = Pod::Weaver::Parser::Nesting->read_file('t/eg/nested-over.pod');

my $want = [
  {
    cmd('head1'),
    content  => "DESCRIPTION\n",
    children => [
      { txt("Foo.\n") },
      {
        cmd('over'),
        content  => "\n",
        children => [
          { cmd('item'), content => "* one\n" },
          {
            cmd('over'),
            content  => "\n",
            children => [
              { cmd('item'), content => "* oneone\n" },
              { cmd('item'), content => "* twotwo\n" },
            ]
          },
          { cmd('item'), content => "* two\n" },
        ]
      },

      {
        cmd('head2'),
        content  => "Sub-Description\n",
        children => [ { txt("Bar.\n") } ],
      },
    ],
  },
  {
    cmd('head1'),
    content => "Final\n",
    children => [ { txt("Baz.\n") } ],
  },
];

cmp_deeply(
  [ map {$_->as_hash} @$chunks ],
  $want,
  'nested =over is not a problem'
);

sub cmd { return(type => 'command', command => $_[0]) }
sub txt { return(type => 'text',    content => $_[0]) }
