# $Id: pbib-export_old.pl 6 2004-10-17 13:48:08Z tandler $
#
# export all references in the Biblio DB
# to a format supported by bp (e.g. bibtex)
#

use strict;
use warnings;

# for debug
use Data::Dumper;

# used modules
use Getopt::Long;

# used own modules
use Biblio::Biblio;
use Biblio::BP;

# select destination format etc.
Biblio::BP::format('auto:auto', 'bibtex:tex');
@ARGV = Biblio::BP::stdargs(@ARGV);

#
#
# the following has been taken from bp's conv.pl
# and adapted to Biblio package (ptandler, 02-03-28)
#
#

my (@files, $outfile);

while (@ARGV) {
  $_ = shift @ARGV;
  /^--$/      && do { push(@files, @ARGV);  last; };
  /^--?help$/   && do { &dieusage; };
  /^--?to/      && do { $outfile = shift @ARGV; next; };
  /^-/        && do { print STDERR "Unrecognized option: $_\n"; next; };
  push(@files, $_);
}

# Note that unlike some programs like rdup, we can be used as a pipe, so
# we can't die with a usage output if we have no arguments.

##### input from STDIN if nothing was specified.
####unshift(@files, '-') unless @files;
# output to STDOUT if nothing was specified.
$outfile = '-' unless defined $outfile;
# check that if the file exists, we can write to it.
if (-e $outfile && !-w $outfile) {
  die "Cannot write to $outfile\n";
}
# check that we won't be overwriting any files.
if ($outfile ne '-') {
  foreach my $file (@files) {
    next if $file eq '-';
    die "Will not overwrite input file $file\n" if $file eq $outfile;
  }
}

# print out a little message on the screen
my ($informat, $outformat) = Biblio::BP::format();
print STDERR "Using bp, version ", Biblio::BP::doc('version'), ".\n";
print STDERR "Writing: $outformat\n";
print STDERR "\n";

# clear errors.  Not really necessary.
# Biblio::BP::errors('clear');

print STDERR "query biblio for known references\n";
my $bib = new Biblio::Biblio() or die "Can't open biblio\n";
my $refs = $bib->queryPapers();
### CAUTION: This currently works only if the file is not yet open (I guess ...)
Biblio::BP::export($outfile, $refs);


sub dieusage {
  my($prog) = substr($0,rindex($0,'/')+1);

  my $str =<<"EOU";
Usage: $prog [<bp arguments>] [-to outfile] [bibfile ...]
  -to  Write the output to <outfile> instead of the standard out

  -bibhelp         general help with the bp package
  -supported       display all supported formats and character sets
  -hush            no warnings or error messages
  -debugging=#     set debugging on or off, or to a severity number
  -error_savelines warning/error messages also include the line number
  -informat=IF     set the input format to IF
  -outformat=OF    set the output format to OF
  -format=IF,OF    set the both the input and output formats
  -noconverter     always use the long conversion, never a special converter
  -csconv=BOOL     turn on or off character set conversion
  -csprot=BOOL     turn on or off character protection
  -inopts=ARG      pass ARG as an option to the input format
  -outopts=ARG     pass ARG as an option to the output format

Convert a Refer file to BibTeX:
	$prog  -format=refer,bibtex  in.refer  -to out.bibtex

Convert an Endnote file to an HTML document using the CACM style
	$prog  -format=endnote,output/cacm:html  in.endnote  -to out.html

EOU

  die $str;
}



=head1 History

$Log: pbib-export.pl,v $
Revision 1.6  2003/01/14 11:09:06  ptandler
new config

Revision 1.5  2002/11/05 18:26:33  peter
print error totals

Revision 1.4  2002/11/03 22:10:46  peter
OrigCiteType handling

Revision 1.3  2002/08/08 08:19:02  Diss
- convert charset from pbib's internal to canan charset before exporting

Revision 1.2  2002/06/03 11:33:15  Diss
default output format is now bibtex

Revision 1.1  2002/03/28 13:23:00  Diss
added pbib-export.pl, with some support for bp


=cut