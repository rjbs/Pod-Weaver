package Pod::Weaver::Weaver::License;
use Moose;
with 'Pod::Weaver::Role::Weaver';

sub weave {
# if ($arg->{license} and ! (_h1(COPYRIGHT => @pod) or _h1(LICENSE => @pod))) {
#   push @pod, (
#     { type => 'command', command => 'head1',
#       content => "COPYRIGHT AND LICENSE\n" },
#     { type => 'text', content => $arg->{license}->notice }
#   );
# }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
