#  Mostly lifted from version_without_package.t but with different data section.
use strict;
use warnings;

use Test::More;
use Test::Differences;

use PPI;

use Pod::Elemental;
use Pod::Weaver;

do_weave( configer( ), 'script_name_t1' );

sub configer {
  my %opts = @_;

  # TODO Hmpf, is there an easier way for this? --APOCAL
  my $assembler = Pod::Weaver::Config::Assembler->new;
  $assembler->sequence->add_section( $assembler->section_class->new({ name => '_' }) );
  $assembler->change_section('@CorePrep');
  $assembler->change_section('Name');
  $assembler->change_section('Version');
  foreach my $k ( keys %opts ) {
    $assembler->add_value( $k => $opts{ $k } );
  }
  $assembler->change_section('Leftovers');

  return Pod::Weaver->new_from_config_sequence( $assembler->sequence );
}

sub do_weave {
  my( $weaver, $filename ) = @_;

  my $in_pod   = do { local $/; open my $fh, '<:raw:bytes', "t/eg/$filename.in.pod"; <$fh> };
  my $expected = do { local $/; open my $fh, '<:encoding(UTF-8)', "t/eg/$filename.out.pod"; <$fh> };
  my $document = Pod::Elemental->read_string($in_pod);

  my $ppi_document  = PPI::Document::File->new("t/eg/$filename.in.pl");

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

