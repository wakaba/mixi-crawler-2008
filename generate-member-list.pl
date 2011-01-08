#!/usr/bin/perl
use strict;

BEGIN { require 'config.pl' }
use File::Path;

our $DataDirectoryName;
our $MemberListDirectoryName;

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

my @error;
mkpath ($MemberListDirectoryName, {error => \@error});
if (@error) {
  unshift @error, qq[Can' create directory "$MemberListDirectoryName"];
  add_to_log (@error);
}

for my $community_id (@community_id) {
  my $community_directory_name = $DataDirectoryName . $community_id . q[/];
  if (-f $community_directory_name . 'OK') {
    my $c_member_id_list_file_name = $MemberListDirectoryName . $community_id;
    if (-f $c_member_id_list_file_name) {
      info ("There is member list for $community_id; skipped");
    } else {
      info ("Community $community_id...");
      open my $c_member_id_list_file, '>', $c_member_id_list_file_name
          or die "$0: $c_member_id_list_file_name: $!";

      my $page_number = 1;
      {
        my $page_file_name = $community_directory_name . q[page-] . $page_number . q[.html];
        if (-f $page_file_name) {
          open my $page_file, '<', $page_file_name or fatal_error "$0: $page_file_name: $!";
          local $/ = undef;
          my $page = <$page_file>;
          while ($page =~ m[<div class="iconListImage"><a href="show_friend\.pl\?id=(\d+)"]g) {
            print $c_member_id_list_file "$1\n";
          }
          $page_number++;
          redo;
        }
      }
    }
  } else {
    info ("Member list HTML files for $community_id is not available");
  }
}
