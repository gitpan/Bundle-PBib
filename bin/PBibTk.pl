#! /usr/bin/perl -w
# --*-Perl-*--
# $Id: PBibTk.pl 18 2004-12-12 07:41:44Z tandler $
#
# little GUI for my refs ...
#

use FindBin;
use lib "$FindBin::Bin/../lib", '$FindBin::Bin/../lib/Biblio/bp/lib';
use PBibTk::LitRefs;
use PBibTk::Main;
use strict;

my $litrefs = new PBibTk::LitRefs();
$litrefs->processArgs();

my $ui = new PBibTk::Main($litrefs);
$ui->main();

#
# $Log: litUI.pl,v $
# Revision 1.2  2002/10/11 10:11:41  peter
# unchanged
#
# Revision 1.1  2002/01/19 00:47:59  ptandler
# - new LitUI.pm and litUI.pl
# - minor changes
#