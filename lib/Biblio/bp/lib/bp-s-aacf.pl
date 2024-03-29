
#
# generated by genmod v1.0
#
# style aacf
#

$record_number = 0;

sub conv_aacf {
  local(%can) = @_;
  $record_number++;

  if (!defined $can{'CiteType'}) {
    &bib'gotwarn("required field CiteType is not defined");
    $can{'CiteType'} = 'misc';
  }
  local($date) = undef;
  if (defined $can{'Month'}) {
    local($mo) = &bp_util'output_month($can{'Month'}, 'short');
    if (defined $can{'Year'}) {
      $date = "$mo $can{'Year'}";
    } else {
      $date = $mo;
    }
  } else {
    $date = $can{'Year'} if defined $can{'Year'};
  }

  if (defined $can{'Year'}) {
    $can{'CiteKey'} = $can{'Year'};
  } else {
    $can{'CiteKey'} = "????";
  }
  if ($can{'CiteKey'} =~ /\d\d\d\d/) {
    $can{'CiteKey'} = &bp_util'regkey($can{'CiteKey'});
  }
  # set default type using the CiteType field
  $type = &aacf_default_type($can{'CiteType'});

  # Initialize output string
  $str = '';
  $str .= "m1100";


  if      ($type eq 'book') {
    if (defined $can{'Authors'}) {
      local($tAuthors);
      $tAuthors = &bp_util'canon_to_name($can{'Authors'}, 'lname1');
      $str .= "$tAuthors ";
    }
    if (defined $can{'Editors'}) {
      local($tEditors);
      $tEditors = &bp_util'canon_to_name($can{'Editors'}, 'lname1');
      $str .= "$tEditors, Ed. ";
    }
    $str .= "($can{'CiteKey'}). "        if defined $can{'CiteKey'};
    $str .= "$can{'Title'}. "            if defined $can{'Title'};
    $str .= "$can{'SuperTitle'}, "       if defined $can{'SuperTitle'};
    $str .= "$can{'PubAddress'}: "       if defined $can{'PubAddress'};
    $str .= "$can{'Publisher'}. "        if defined $can{'Publisher'};
  } elsif ( ($type eq 'inbook') || ($type eq 'misc') ) {
    if (defined $can{'Authors'}) {
      local($tAuthors);
      $tAuthors = &bp_util'canon_to_name($can{'Authors'}, 'lname1');
      $str .= "$tAuthors ";
    }
    $str .= "($can{'CiteKey'}). "        if defined $can{'CiteKey'};
    $str .= "\"$can{'Title'}\". "        if defined $can{'Title'};
    if (defined $can{'Editors'}) {
      local($tEditors);
      $tEditors = &bp_util'canon_to_name($can{'Editors'}, 'lname1');
      $str .= "$tEditors, Ed. ";
    }
    $str .= "$can{'SuperTitle'}. "       if defined $can{'SuperTitle'};
    $str .= "$can{'Pages'}. "            if defined $can{'Pages'};
    $str .= "$can{'PubAddress'}: "       if defined $can{'PubAddress'};
    $str .= "$can{'Publisher'}. "        if defined $can{'Publisher'};
  } elsif ($type eq 'article') {
    if (defined $can{'Authors'}) {
      local($tAuthors);
      $tAuthors = &bp_util'canon_to_name($can{'Authors'}, 'lname1');
      $str .= "$tAuthors ";
    }
    $str .= "($can{'CiteKey'}). "        if defined $can{'CiteKey'};
    $str .= "\"$can{'Title'}.\" "        if defined $can{'Title'};
    if (defined $can{'Journal'}) {
      $str .= "$can{'Journal'} ";
      $str .= "$can{'Volume'}:"          if defined $can{'Volume'};
      $str .= "$can{'Pages'}"            if defined $can{'Pages'};
      $str .= ". ";
    }
  } elsif ($type eq 'thesis') {
    if (defined $can{'Authors'}) {
      local($tAuthors);
      $tAuthors = &bp_util'canon_to_name($can{'Authors'}, 'lname1');
      $str .= "$tAuthors ";
    }
    $str .= "($can{'CiteKey'}). "        if defined $can{'CiteKey'};
    $str .= "$can{'Title'}. "            if defined $can{'Title'};
    $str .= "$can{'ReportType'}. "       if defined $can{'ReportType'};
    $str .= "$can{'School'}. "           if defined $can{'School'};
  } 
  $str =~ s/.\s+$/./;

  $str .= "\n";

  $str;
}

sub aacf_default_type {
  local($citetype) = @_;
  local($type) = 'misc';

  if (defined $citetype) {
    if ($citetype =~ /^(book|inbook|misc|article|thesis)$/) {
      $type = $citetype;
    } else {
      &bib'gotwarn("Type '$can{'CiteType'}' not recognized -- using default type 'misc'");
    }
  }
  $type;
}

1;
