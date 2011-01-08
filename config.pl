use strict;

## --- Parameters

## User account used to retrieve mixi-local HTML documents
our $UserMailAddress = q[XXX@example.com];
our $UserPassword = q[XXX];

## Directory in which result data are stored
our $DataDirectoryName = q[data/];
our $CommunityListDirectoryName = $DataDirectoryName . q[list/];
our $MemberListDirectoryName = $DataDirectoryName . q[member-ids/];

## Log files
our $LogFileName = q[mixicrawler.log];
our $FailedCommunityListFileName = q[in-error-community-list];

our $GetDuration = 2; ## Interval between two GET requests [s]

our $MaxCommunityNumber = 100; ## Number of communities to retrieve

## --- Logger

{
  require IO::Handle;
  open my $log_file, '>>', $LogFileName or die "$0: $LogFileName: $!";
  $log_file->autoflush;
  sub add_to_log (@) {
    print $log_file "[" . (scalar gmtime) . "]\t" . (join "\t", @_) . "\n";
  }
  sub info (@) {
    for ("[" . (scalar gmtime) . "]\t(Info)\t" . join "\t", @_) {
      print $log_file $_, "\n";
      warn $_, "\n";
    }
  }
  sub fatal_error (@) {
    add_to_log (@_);
    close $log_file;
    die @_;
  }
}

1;
