#
# test the pbib module
#
use strict;
use Test::More tests => 9 + 3 * 2; # no. file types * 2
use File::Compare;
use File::Spec;

BEGIN {
	use_ok( 'Biblio::Biblio' );
	use_ok( 'PBib::Config' );
	use_ok( 'PBib::PBib' );
}


# for this test, only rely on default config
my $config = new PBib::Config(
	argv => 0,
	env => 0,
	site => 0,
	user => 0,
	default => 1,
	verbose => 0,
	quiet => 1,
	);
isnt($config, undef, "new PBib::Config");


my $bib = new Biblio::Biblio(
	file => 't/sample.bib',
	verbose => 0,
	quiet => 1,
	);
isnt($bib, undef, "open biblio database");


my $refs = $bib->queryPapers();
isnt($refs, undef, "queryPapers()");
# I do assume that sample.bib is read correctly
# as this is tested in 20-biblio.t


# process files

my $pbib = new PBib::PBib('refs' => $refs,
	'config' => $config,
	);
isnt($pbib, undef, "new PBib::PBib()");
is($pbib->config()->option("quiet"), 1, "option('quiet') for this test");
is($pbib->config()->beQuiet(), 1, "beQuiet() for this test");

my %files = qw(
	sample.rtf sample-pbib.rtf
	sample.sxw sample-pbib.sxw
	sample.txt sample-pbib.txt
	);
	#  sample.doc sample-pbib.doc
	#### this simple compare does not work for MS Word generated files
	#  sample.html sample-pbib.html
	#  sample.xml sample-pbib.xml
my $dir = 't';

foreach my $file (sort keys %files) {
	SKIP: {
		my $output = File::Spec->catfile($dir, $files{$file});
		my $expected = File::Spec->catfile($dir, "expected-" . $files{$file});
		$file = File::Spec->catfile($dir, $file);
		diag("Converting $file ...");
		unlink($output) if -e $output; # delete output file first
		unlink("$output.log") if -e "$output.log";
		ok( -r $expected, "$expected is readable");
		$pbib->convertFile($file);
		# compare result with expected result
		ok(File::Compare::compare($output, $expected) == 0, "PBib::convertFile($file) produces expected output file");
	}
}
