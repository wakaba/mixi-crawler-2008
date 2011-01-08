#!/usr/bin/perl 
use strict;

require WWW::Mixi;
use File::Path;

BEGIN { require 'config.pl' }
our $DataDirectoryName;
our $GetDuration;
our $FailedCommunityListFileName;

my @community_id;
my $community_list_file_name = shift;
fatal_error qq[$0: Community list file is not specified] unless defined $community_list_file_name;
{
  info (qq[Community list "$community_list_file_name"...]);
  open my $community_list_file, '<', $community_list_file_name
      or fatal_error "$0: $community_list_file_name: $!";
  while (<$community_list_file>) {
    if (/^(\d+)$/) {
      push @community_id, 0+$_;
    } elsif (/^\s*$/) {
      #
    } else {
      fatal_error "$0: $community_list_file_name: $.: Syntax error";
    }
  }
}

for my $community_id (@community_id) {
  my $community_directory_name = $DataDirectoryName . $community_id . q[/];
  
  if (-f $community_directory_name . 'OK') {
    info ("Member list of community $community_id has already been fetched");
    next;
  } elsif (-f $community_directory_name . 'ERROR') {
    info ("Member list of community $community_id has already been in error or in progress");
    next;
  }
  
  info ("Fetching member list of community $community_id...");
  system 'perl', 'get-members-in-community.pl', $community_id;

  unless (-f $community_directory_name . 'OK') {
    open my $failure_list_file, '>>', $FailedCommunityListFileName
        or fatal_error qq[$0: $FailedCommunityListFileName: $!];
    print $failure_list_file $community_id, "\n";
    close $failure_list_file;
  }
  
  sleep $GetDuration;
}

info (qq["$community_list_file_name" done]);
