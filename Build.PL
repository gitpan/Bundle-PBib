# $Id: PBib.pm 13 2004-11-27 08:58:44Z tandler $

use FindBin;
use lib "$FindBin::Bin/lib";
use PBib::Builder;

my $b = PBib::Builder->new
	(
		dist_name => 'Bundle-PBib',
		module_name => 'PBib::PBib',
		license => 'perl',
		
		# PBib::Builder extensions for Inno Setup:
		app_name => 'PBib',
		#  app_version => '1.0',
		app_exe => 'bin\\PBibTk.pl', # name of the main executable
		author_url => 'http://tandlers.de/peter/',
		support_url => 'http://tandlers.de/peter/pbib',
		updates_url => 'http://tandlers.de/peter/pbib',
		
		requires => {
				'perl' => '5.6.1', # I've tested with 5.8
				'Bundle::DBI' => '11.02',
				'Config::General' => '2.18',
				'Cwd' => '2.06',
				'Data::Dumper' => '2.12',
			},
		recommends => {
				'DBD::ODBC' => '1.0',
				'DBD::mysql' => '2.1',
				'Tk' => '800.024',		# for PBibTk.pl
				'Win32::OLE' => '0.16',	# for PBibTk.pl, MS Word support
				'Win32::Clipboard' => '0.51',	# for PBibTk.pl
				'Archive::Zip' => '1.13', # for OpenOffice support
				'XML::Parser' => '2.31', # for OpenOffice and XML support
			},
		build_requires => {
			},
		
		script_files => [qw(
			bin/pbib.pl
			bin/pbib-export.pl
			bin/pbib-import.pl
			bin/PBibTk.pl
			)],
		
		create_makefile_pl => 'passthrough',
		create_readme => 1,
		sign => 1,
		
		# PBib::Builder extensions
		config_srcdir => '.',
		config_destdir => 'lib/PBib',
		config_pattern => qr{^./(conf|styles)/.*\.pbib$},
		
		htmldocs => {
			'lib/PBib/Intro.pod' => 'docs/Intro.html',
			'lib/PBib/PBib.pm' => 'docs/Overview.html',
			},
	);

$b->register_config_files(); # process config_* parameters

# add bp files to install list
{
	my $self = $b;
	my $pm_files = $self->find_pm_files();
	my $bp_files = $self->rscan_dir('./lib/Biblio/bp', qr{.*\.pl$});
	foreach my $src (@$bp_files) {
		$src = $self->localize_file_path($src);
		$pm_files->{$src} = $src;
	}
	$self->{properties}->{pm_files} = $pm_files;
}

$b->create_build_script();
#  $b->dispatch('innosetupscript');


