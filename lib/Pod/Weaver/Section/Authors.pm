package Pod::Weaver::Section::Authors;
use Moose;
with 'Pod::Weaver::Role::Section';

sub weave_section {
#  if (
#    $arg->{authors}->length
#    and ! (_h1(AUTHOR => @pod) or _h1(AUTHORS => @pod))
#  ) {
#    my $name = $arg->{authors}->length > 1 ? 'AUTHORS' : 'AUTHOR';
#
#    push @pod, (
#      { type => 'command',  command => 'head1', content => "$name\n" },
#      { type => 'verbatim', content => $arg->{authors}->join("\n") . "\n"
#      }
#    );
#  }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
