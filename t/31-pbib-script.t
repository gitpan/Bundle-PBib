#
# test the pbib script
#
use strict;
use Test::More tests => 2 + 3 * 3; # no. file types * 3
use File::Compare;
use File::Spec;
use FindBin;

# find pbib.pl
my $pbib = File::Spec->catfile($FindBin::Bin, '..', 'bin', 'pbib.pl');
ok( -r $pbib, "'$pbib' exists");
my $perl = $^X;
ok( -x $perl, "'$perl' is executable");

# system("pbib ....");
# for all document types, but only for a single bib data source

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

# setup test configuration for pbib
$ENV{PBIB_CONFIG} = join(',', qw(
	argv=0
	env=0
	site=0
	user=0
	default=1
	verbose=0
	quiet=1
	biblio.file=t/sample.bib));

foreach my $file (sort keys %files) {
	SKIP: {
		my $output = File::Spec->catfile($dir, $files{$file});
		my $expected = File::Spec->catfile($dir, "expected-" . $files{$file});
		$file = File::Spec->catfile($dir, $file);
		diag("Converting $file ...");
		unlink($output) if -e $output; # delete output file first
		ok( -r $expected, "$expected is readable");
		my $result = system($perl, $pbib, $file);
		is($result, 0, "system($perl, $pbib, $file)");
		skip("running pbib failed", 1) if $result;
		# compare result with expected result
		ok(File::Compare::compare($output, $expected) == 0, "PBib::convertFile($file) produces expected output file");
	}
}

# also test pbib-export, pbib-import (as separate tests!)