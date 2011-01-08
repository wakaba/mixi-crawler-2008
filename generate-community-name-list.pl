#!/usr/bin/perl
use strict;

BEGIN { require 'config.pl' }
our $CommunityListDirectoryName;

my @file_name;
{
  opendir my $dir, $CommunityListDirectoryName or fatal_error "$0: $CommunityListDirectoryName: $!";
  @file_name = map {$CommunityListDirectoryName . $_} grep /^page-\d+\.html$/, readdir $dir;
}

for my $file_name (@file_name) {
  info qq<$file_name...>;
  open my $file, '<', $file_name or fatal_error "$0: $file_name: $!";
  local $/ = undef;
  my $file_content = <$file>;
  while ($file_content =~ m[<dt class="communityTitle"><a href="view_community\.pl\?id=(\d+)">(.+?) \(\d+\)</a>]g) {
    my ($id, $name) = ($1, $2);
    $name =~ s/&lt;/</g;
    $name =~ s/&gt;/>/g;
    $name =~ s/&quot;/"/g;
    $name =~ s/&amp;/&/g;
    print "$id\t$name\n";
  }
}

=head1 NAME

generate-community-name-list.pl - Generate community ID/name list from community list HTML documents

=head1 SYNOPSIS

  perl generate-community-name-list.pl > community-id-list.txt

Input is the HTML documents stored in the directory specified by the variable
I<$CommunityListDirectoryName> defined in C<config.pl>.

The script outputs the newline-separated list of communities, each of which is a tab-separated
list of community ID and (human-readable) name.

=head1 AUTHOR

Wakaba <m-wakaba@ist.osaka-u.ac.jp>.
