#
# bibliography package for Perl
#
# output routines
#
# Dana Jacobsen (dana@acm.org)
# 12 March 1996 (last modified 12 March 1996)
#
# This is the new output scheme.  It uses a style generated by genmod, and
# designated by the style=... option.
#
# This is going to be a bit more complicated than it is right now.  We will
# want to handle open and close ourselves, and deal with lists.
# One lingering problem is that some charsets will have a bit more to deal
# with than others.  For instance, for HTML, we want to have a more specific
# header and trailer.
#

package bp_output;

$version = "output (dj 12 mar 96)";

######

&bib'reg_format(
  'output',    # name
  'out',       # short name
  'bp_output', # package name
  'none',      # default character set
  'suffix is out',
# functions
  'open',
  'close',
  'write',
  'clear',
  'options',
  'read      is unsupported',
  'explode',
  'implode',
  'tocanon   is unsupported',
  'fromcanon',
);

######

%styles = ();
$opt_style = 'generic';
&load_style($opt_style);

$opt_full_document = 1;

# This keeps track of whether we're writing a header or not.  It has three
# values:
#    -1 means don't output headers or trailers
#     0 means it's open but nothing written yet
#     1 means we've written the header already
%file_modes = ();

######

sub options {
  local($opt) = @_;

  &bib'panic("output options called with no arguments!") unless defined $opt;
  &bib'debugs("parsing output option '$opt'", 64);
  if ($opt !~ /=/) {
    # Assume this is a style being asked for.
    $opt =~ s/^/style=/;
  }
  local($_, $val) = split(/\s*=\s*/, $opt, 2);
  &bib'debugs("option split: $_ = $val", 8);
  /^style$/    && do { return &load_style($val); };
  /^full$/     && do { $opt_full_document = 1; return 1; };
  /^list$/     && do { $opt_full_document = 0; return 1; };
  undef;
}

######

sub load_style {
  local($style) = @_;
  # For some reason, $style gets undefined after the eval.  So we store
  # it in the global $opt_style.

  $opt_style = $style;
  $conv_func = "conv_$opt_style";
  return 1 if defined $styles{$opt_style};

  &bib'debugs("loading output style $opt_style...", 1024);
  $func = "require \"${bib'glb_bpprefix}s-$opt_style.pl\";";
  eval $func;
  if ($@) {
    $conv_func = 'conv_generic';
    if ($@ =~ /^Can't locate ${bib'glb_bpprefix}/) {
      return &bib'goterror("style $opt_style is not supported.");
    }
    return &bib'goterror("error in style $opt_style: $@", "module");
  }
  $styles{$opt_style} = 1;

  1;
}

######

sub implode {
  local(%rec) = @_;

  return $rec{'TEXT'} if defined $rec{'TEXT'};
  return &bib'goterror("No TEXT entry in record");
}

######

sub explode {
  local(%rec);
  $rec{'TEXT'} = $_[0];
  %rec;
}

######

sub fromcanon {
  local(%entry) = @_;
  local(%rec) = ();
  local($ent) = '';

  # We do the conversion here rather than in implode because we can put
  # escape characters and meta characters in the style without worrying
  # about which character set is being used.

  # Well, almost.  We do care if we're using HTML, because we want a number
  # of special things done for it.  As of 0.2.2, we have glb_current_cset
  # set for us for fromcanon.
  if ($bib'glb_current_cset eq 'html') {
    #$ent = "${bib'cs_meta}1100\n";
    if (defined $entry{'Source'}) {
      local($url, $title);
      $url = $entry{'Source'};
      $url =~ s/<(.*)>/$1/;
      $url =~ s/^url:\s*(.*)/$1/i;
      if ($url =~ /^\w+:\/\//) {
        $title = $entry{'Title'};
        $entry{'Title'} = "${bib'cs_meta}2200" . "${bib'cs_meta}2300"
                        . $url   . "${bib'cs_meta}2310"
                        . $title . "${bib'cs_meta}2210";
      }
    }
  }

  $ent .= &$conv_func(%entry);

  #$ent =~ s/\s\s+/ /g;
  $ent =~ s/$bib'cs_sep/ ; /go;

  $rec{'TEXT'} = $ent;

  %rec;
}

######

sub open {
  local($file) = @_;
  local($name, $mode);

  &panic("output open called with no arguments") unless defined $file;

  # get the name and mode
  if ($file =~ /^>>(.*)/) {
    $mode = 'append';  $name = $1;
    # XXXXX we assume that we're in the middle of a list already.
    #       We also assume we don't want any trailers written.
    #       I think this is correct.
    $file_modes{$name} = -1  unless defined $file_modes{$name};
  } elsif ($file =~ /^>(.*)/) {
    $mode = 'write';   $name = $1;
#print STDERR "name: $file";
#print STDERR ", oldmode: $file_modes{$name}" if defined $file_modes{$name};
    &close($file) if defined $file_modes{$name};
    $file_modes{$name} = 0;
#print STDERR ", mode: $file_modes{$name}\n";
  } else {
    $mode = 'read';    $name = $file;
    $file_modes{$name} = -1  unless defined $file_modes{$name};
  }
  $file_modes{$name} = -1  unless $opt_full_document;

  if ($mode eq 'write') {
    &bib'debugs("output write", 128, 'module');
    return &bib'goterror("Can't open file $file")
           unless open($bib'glb_current_fh, $file);
    return $bib'glb_current_fmt;
  } elsif ($mode eq 'append') {
    &bib'debugs("output append", 128, 'module');
    return &bib'goterror("Can't open file $file")
           unless open($bib'glb_current_fh, $file);
    # XXXXX Is there anything special we should do here?
    return $bib'glb_current_fmt;
  } else {
    &bib'debugs("output read", 128, 'module');
    # XXXXX What exactly would this mean?  Skip headers of some kind?
    return $bib'glb_current_fmt  if open($bib'glb_current_fh, $file);
    &bib'goterror("Can't open file $file");
  }
}

######

sub close {
  local($file) = @_;

  &panic("output close called with no arguments")  unless defined $file;

  if (    $opt_full_document
       && (defined $file_modes{$file})
       && ($file_modes{$file} == 1)
       && (defined $tailstr{$bib'glb_current_cset})
     ) {
    print $bib'glb_current_fh $tailstr{$bib'glb_current_cset};
  }

  &bib'clear($file);

  close($bib'glb_current_fh);
}

######

sub write {
  local($file, $out) = @_;
  local($outstr, $bibname);

  &panic("output write called with no arguments")  unless defined $file;
  &panic("output write called with no output")     unless defined $out;

  &bib'debugs("writing $file<html>", 32);

  if ($file_modes{$file} == 0) {
    $file_modes{$file} = 1;
    if (defined $headstr{$bib'glb_current_cset}) {
      local($outstr, $bibname);
      $outstr = $headstr{$bib'glb_current_cset};
      # XXXXX Why not use $file for bibname?
      if (defined $bib'glb_Ifilename) {
        $bibname = $bib'glb_Ifilename;
      } else {
        $bibname = '';
      }
      # get the first two occurances of this.
      $outstr =~ s/Bibliography: =name=/Bibliography: $bibname/;
      $outstr =~ s/Bibliography: =name=/Bibliography: $bibname/;
      print $bib'glb_current_fh $outstr;
    }
  }
  print $bib'glb_current_fh ($out, "\n\n");
}

######

sub clear {
  local($file) = @_;

  undef $file_modes{$file};
  1;
}

######

#
# Headers and trailers for various character sets.
# This ought to go into a style file of some kind.
#

%headstr = ();
%tailstr = ();

$headstr{'html'} =<<"EOH-HTML";
<HTML><HEAD>
<LINK REV="made" HREF="http://www.ecst.csuchico.edu/~jacobsd/bib/bp/index.html">
<!-- Created by bp $bib'glb_version -->
<TITLE>Bibliography: =name=</TITLE>
</HEAD>

<BODY><H1 align=center>Bibliography: =name=</H1>

EOH-HTML

$tailstr{'html'} =<<"EOT-HTML";
<HR>
<ADDRESS>
<I>Created automatically by bp $bib'glb_version
using module $version, style $opt_style.</I>
</ADDRESS>
</BODY></HTML>
EOT-HTML


#######################
# end of package
#######################

1;
