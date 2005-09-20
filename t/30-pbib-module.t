#
# test the pbib module
#
use strict;
use Test::More;
use File::Compare;
use File::Spec;

BEGIN {
	my @features = eval("use PBib::PBib::ConfigData; PBib::PBib::ConfigData->feature_names();");
	if( @features ) {
		plan( tests => 10 + 5 * 3 ); # no. file types * 3
	} else {
		plan(skip_all => "This test need the ConfigData generated by Module::Build. This should be available in blib, e.g. use perl -Mblib=blib or if PBib is installed correctly");
		}
	use_ok( 'PBib::PBib::ConfigData' );
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


# to be able to test which features are enabled in this installation
my %types = qw(
	rtf MSWord
	sxw OpenOffice
	txt 0
	html 0
	xml XML
	);
	# doc MSWord #### this simple file compare does not work for MS Word generated files
my $dir = 't';

foreach my $ext (sort keys %types) {
	SKIP: {
		# is this file format enabled?
		if( $types{$ext} ) {
			skip("Support for $types{$ext} documents is not enabled", 3)
				unless( PBib::PBib::ConfigData->feature("doc_$types{$ext}") );
		}
		
		my $file = File::Spec->catfile($dir, "sample.$ext");
		my $output = File::Spec->catfile($dir, "sample-pbib.$ext");
		my $expected = File::Spec->catfile($dir, "expected-sample-pbib.$ext");
		
		diag("Converting $file ...");
		unlink($output) if -e $output; # delete output file first
		unlink("$output.log") if -e "$output.log";
		ok( -r $file, "$file is readable");
		ok( -r $expected, "$expected is readable");
		unless( -r $file && -r $expected ) {
			skip("Test files missing, maybe the distribution is corrupt.", 1);
		}
		$pbib->convertFile($file);
		# compare result with expected result
		ok(File::Compare::compare($output, $expected) == 0, "PBib::convertFile($file) produces expected output file");
	}
}
