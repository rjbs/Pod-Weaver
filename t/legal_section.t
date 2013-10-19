use strict;
use warnings;

use Test::More;
use Test::Differences;
use Moose::Autobox 0.10;

use PPI;

use Pod::Elemental;
use Pod::Weaver;

use Software::License::Perl_5;

# Test various combinations of options for Section::Legal
do_weave( configer( ), 'legal_t1' );
do_weave( configer( license_file => 'LICENSE' ), 'legal_t2' );

sub configer {
  my %opts = @_;

  # TODO Hmpf, is there an easier way for this? --APOCAL
  my $assembler = Pod::Weaver::Config::Assembler->new;
  $assembler->sequence->add_section( $assembler->section_class->new({ name => '_' }) );
  $assembler->change_section('@CorePrep');
  $assembler->change_section('Name');
  $assembler->change_section('Leftovers');
  $assembler->change_section('Legal');
  foreach my $k ( keys %opts ) {
    $assembler->add_value( $k => $opts{ $k } );
  }

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
    license => Software::License::Perl_5->new({
      holder => 'RJBS',
      year => '2010',
    }),
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
