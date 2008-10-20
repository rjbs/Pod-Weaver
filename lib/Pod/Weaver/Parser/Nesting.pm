use strict;
use warnings;
package Pod::Weaver::Parser::Nesting;
use Pod::Weaver::Parser::Simple;
BEGIN { our @ISA = 'Pod::Weaver::Parser::Simple'; }

use Moose::Autobox;

sub read_handle {
  my ($self, @args) = @_;

  # XXX: Argh, hate! -- rjbs, 2008-10-19
  $self = $self->new unless ref $self;

  my $events = $self->SUPER::read_handle(@args);

  $events = $self->nestify_events($events);

  return $events;
}

my %RANK = do {
  my $i = 0;
  map { $_ => $i++ } qw(head1 head2 head3 head4 over item begin for);
};

sub nestify_events {
  my ($self, $events) = @_;

  my $top = Pod::Weaver::PodChunk->new({
    type     => 'command',
    command  => 'pod',
    content  => "\n",
  });

  my @stack  = $top;

  EVENT: while (my $event = $events->shift) {
    # =cut?  Where we're going, we don't need =cut. -- rjbs, 2025-11-05
    next if $event->type eq 'command' and $event->command eq 'cut';

    if ($event->type ne 'command') {
      $stack[-1]->children->push($event);
      next EVENT;
    }

    # XXX: Refactor the following two blocks -- rjbs, 2008-10-20
    if ($event->command eq 'back') {
      pop @stack until !@stack or $stack[-1]->command eq 'over';
      Carp::croak "encountered =back without =over" unless @stack;
      $stack[-1]->children->push($event);
      next EVENT;
    }

    if ($event->command eq 'end') {
      pop @stack until !@stack or $stack[-1]->command eq 'begin';
      Carp::croak "encountered =end without =begin" unless @stack;
      $stack[-1]->children->push($event);
      next EVENT;
    }

    pop @stack until @stack == 1 or defined $RANK{ $stack[-1]->command };

    my $rank        = $RANK{ $event->command };
    my $parent_rank = $RANK{ $stack[-1]->command } || 0;

    if (@stack > 1) {
      if (! $rank) {
        @stack = $top;
      } elsif ($rank < $parent_rank) {
        pop @stack until @stack == 1 or $parent_rank < $rank;
      }
    }

    # printf "parent is =%s; pushing a %s/%s (rank %s)\n",
    #   $stack[-1]->command, $event->type, ($event->command||''),
    #   (defined $rank ? $rank : '-');

    $stack[-1]->children->push($event);
    @stack->push($event);
  }

  return scalar $top->children;
}

1;
