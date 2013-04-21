use strict;
use warnings;

use Test::More;
use Test::Differences;
use Moose::Autobox 0.10;

use PPI;

use Pod::Elemental;
use Pod::Weaver;

# Test various combinations of options for Section::Version
do_weave( configer( ), 'version_t1' );
do_weave( configer( is_verbatim => 1 ), 'version_t2' );
do_weave( configer( format => "%v FOOBAZ" ), 'version_t3' );
do_weave( configer( format => "%t%v%t-%t%m", is_verbatim => 1 ), 'version_t4' );

# In order to test DateTime, we have to avoid touching the time! Hence UTC and the weird CLDR here...
do_weave( configer( format => "%v - %{ZZZZ G}d", time_zone => 'UTC' ), 'version_t5' );

TODO: {
  local $TODO = 'not implemented yet';
  do_weave( configer( format => ["%v", "FOOBAZ", "", "EXPLANATION"] ), 'version_t6' );
}

sub configer {
  my %opts = @_;

  # TODO Hmpf, is there an easier way for this? --APOCAL
  my $assembler = Pod::Weaver::Config::Assembler->new;
  $assembler->sequence->add_section( $assembler->section_class->new({ name => '_' }) );
  $assembler->change_section('@CorePrep');
  $assembler->change_section('Name');
  $assembler->change_section('Version');
  foreach my $k ( keys %opts ) {
    if (ref $opts{ $k }) {
      $assembler->add_value( $k => $_ ) for @{ $opts{ $k } };
    }
    else {
      $assembler->add_value( $k => $opts{ $k } );
    }
  }
  $assembler->change_section('Leftovers');

  return Pod::Weaver->new_from_config_sequence( $assembler->sequence );
}

my $perl_document;
sub do_weave {
  my( $weaver, $filename ) = @_;

  my $in_pod   = do { local $/; open my $fh, '<:encoding(UTF-8)', "t/eg/$filename.in.pod"; <$fh> };
  my $expected = do { local $/; open my $fh, '<:encoding(UTF-8)', "t/eg/$filename.out.pod"; <$fh> };
  my $document = Pod::Elemental->read_string($in_pod);

  $perl_document = do { local $/; <DATA> } if ! defined $perl_document;
  my $ppi_document  = PPI::Document->new(\$perl_document);

  my $woven = $weaver->weave_document({
    pod_document => $document,
    ppi_document => $ppi_document,
    version  => '1.012078',
  });

  # XXX: This test is extremely risky as things change upstream.
  # -- rjbs, 2009-10-23
  eq_or_diff(
    $woven->as_pod_string,
    $expected,
    "exactly the pod string we wanted after weaving for $filename!",
  );
}

done_testing;

__DATA__

package Module::Name;
# ABSTRACT: abstract text

my $this = 'a test';
