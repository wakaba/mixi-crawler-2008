#!/usr/bin/perl 
use strict;

require WWW::Mixi;
use File::Path;

BEGIN { require 'config.pl' }
our $UserMailAddress;
our $UserPassword;
our $CommunityListDirectoryName;
our $GetDuration;
our $MaxCommunityNumber;

my @error;
mkpath ($CommunityListDirectoryName, {error => \@error});
if (@error) {
  unshift @error, qq[Can' create directory "$CommunityListDirectoryName"];
  add_to_log (@error);
}

my $mixi = WWW::Mixi->new ($UserMailAddress, $UserPassword, -log => sub {
  shift; # $mixi
  add_to_log (@_);
});
$mixi->login->is_success or fatal_error "$0: Can't login";

my $community_number = 0;

my $page_number = 1;
{
  my $c_page_uri = q<http://mixi.jp/search_community.pl?page=> . $page_number
      . q<&category_id=24&sort=member&ad=a0bf1f9505f87d442742210adb095339&mode=title&submit=main&ap=4>;
  my $c_page_response = $mixi->get ($c_page_uri);
  if ($c_page_response->is_success) {
    my $c_page_file_name = $CommunityListDirectoryName . q[page-] . $page_number . q[.html];
    info (qq[<$c_page_uri> => "$c_page_file_name"]);
    open my $c_page_file, '>', $c_page_file_name or fatal_error "$0: $c_page_file_name: $!";
    my $c_page_message = $c_page_response->as_string;
    print $c_page_file $c_page_message;
    
    ## NOTE: As far as I can tell, |$mixi->get_list_community| does not work;
    ## maybe due to changes to the output format of search_community.pl.
    
    while ($c_page_message =~ m[<p><a href="view_community\.pl\?id=(\d+)">]g) {
      print "$1\n";
      $community_number++;
      if ($community_number >= $MaxCommunityNumber) {
        last;
      }
    }
    
    if ($community_number < $MaxCommunityNumber and
        $c_page_message =~ m[<a[^<>]+>次を表示</a>]) {
      $page_number++;
      sleep $GetDuration;
      redo;
    }
  } else {
    add_to_log ("Can't retrieve <$c_page_uri> (@{[$c_page_response->status_line]})");
  }
}
