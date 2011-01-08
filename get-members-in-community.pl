#!/usr/bin/perl 
use strict;

require WWW::Mixi;
use File::Path;

BEGIN { require 'config.pl' }
our $UserMailAddress;
our $UserPassword;
our $DataDirectoryName;
our $GetDuration;

my $community_id = shift or fatal_error "$0: Community identifier is not specified";
my $community_directory_name = $DataDirectoryName . $community_id . q[/];

my @error;
mkpath ($community_directory_name, {error => \@error});
if (@error) {
  unshift @error, qq[Can' create directory "$community_directory_name"];
  add_to_log (@error);
}

{
  open my $file, '>', $community_directory_name . 'ERROR'
      or fatal_error "$0: ${community_directory_name}ERROR: $!";
  close $file;
}

my $mixi = WWW::Mixi->new ($UserMailAddress, $UserPassword, -log => sub {
  shift; # $mixi
  add_to_log (@_);
});
$mixi->login->is_success or fatal_error "$0: Can't login";

my $page_number = 1;
{
  my $c_page_uri = q<http://mixi.jp/list_member.pl?page=> . $page_number . q<&id=> . $community_id;
  my $c_page_response = $mixi->get ($c_page_uri);
  if ($c_page_response->is_success) {
    my $c_page_file_name = $community_directory_name . q[page-] . $page_number . q[.html];
    info (qq[<$c_page_uri> => "$c_page_file_name"]);
    open my $c_page_file, '>', $c_page_file_name or fatal_error "$0: $c_page_file_name: $!";
    my $c_page_message = $c_page_response->as_string;
    print $c_page_file $c_page_message;
    if ($c_page_message =~ m[<a href=list_member\.pl\?page=\d+&id=\d+>次を表示</a>]) {
      $page_number++;
      sleep $GetDuration;
      redo;
    }
  } else {
    add_to_log ("Can't retrieve <$c_page_uri> (@{[$c_page_response->status_line]})");
  }
}

{
  open my $file, '>', $community_directory_name . 'OK'
      or fatal_error "$0: ${community_directory_name}OK: $!";
  close $file;
  unlink $community_directory_name . 'ERROR';
}
