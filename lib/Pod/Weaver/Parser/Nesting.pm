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

sub can_recurse {
  my ($self, $event) = @_;
  return 1 if $event->command eq [ qw(over begin) ]->any;
  return 0;
}

sub rank_for {
  my ($self, $event) = @_;
  return $RANK{ $event->command };
}

sub nestify_events {
  my ($self, $events) = @_;

  my $top = Pod::Weaver::PodChunk->new({
    type     => 'command',
    command  => 'pod',
    content  => "\n",
  });

  my @stack  = $top;

  EVENT: while (my $event = $events->shift) {
    # =cut?  Where we're going, we don't need =cut. -- rjbs, 2015-11-05
    next if $event->type eq 'command' and $event->command eq 'cut';

    if ($event->type ne 'command') {
      $stack[-1]->children->push($event);
      next EVENT;
    }

    if ($event->command eq 'begin') {
      # =begin/=end are treated like subdocuments; we're going to look ahead
      # for the balancing =end, then pass the whole set of events to a new
      # nestification process -- rjbs, 2008-10-20
      my $level  = 1;
      my @subdoc;

      SUBEV: while ($level and my $next = $events->shift) {
        if (
          $next->type eq 'command'
          and $next->command eq 'begin'
          and $next->content eq $event->content
        ) {
          $level++;
          push @subdoc, $next;
          next SUBEV;
        }

        if (
          $next->type eq 'command'
          and $next->command eq 'end'
          and $next->content eq $event->content
        ) {
          $level--;
          push @subdoc, $next if $level;
          next SUBEV;
        }

        push @subdoc, $next;
      }

      $event->children->push( $self->nestify_events(\@subdoc)->flatten );
      $stack[-1]->children->push( $event );
      next EVENT;
    }

    if ($event->command eq 'back') {
      pop @stack until !@stack or $stack[-1]->command eq 'over';
      Carp::croak "encountered =back without =over" unless @stack;
      pop @stack; # we want to be outside of the 
      next EVENT;
    }

    if ($event->command eq 'end') {
      Carp::croak "encountered =end outside matching =begin";
    }

    pop @stack until @stack == 1 or defined $self->rank_for($stack[-1]);

    my $rank        = $self->rank_for($event);
    my $parent_rank = $self->rank_for($stack[-1]) || 0;

    if (@stack > 1) {
      if (! $rank) {
        @stack = $top;
      } else {
        until (@stack == 1) {
          last if $self->rank_for($stack[-1]) < $rank;
          last if $self->can_recurse($event)
              and $event->command eq $stack[-1]->command;

          pop @stack;
        }
      }
    }

    $stack[-1]->children->push($event);
    @stack->push($event);
  }

  return scalar $top->children;
}

1;
