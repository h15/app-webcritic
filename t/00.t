#! /usr/bin/perl
__END__

# TODO: use Fake HTTPD for WebServer

use lib './lib';
use lib './t';
use utf8;
use strict;
use warnings;
use feature ':5.10';
use Data::Dumper;
use Test::More tests => 95;
use App::webcritic::Critic::WebServer::Test;

# Create server
my $dir = './t/00';
my %pages;
{
  my %tmp = dir_to_hash($dir);
  while (my ($k, $v) = each %tmp) {
    $k = substr $k, 1 + length $dir;
    $pages{$k} = $v;
  }
}
my $tester = App::webcritic::Critic::WebServer::Test->new(\%pages);
$tester->run_server;

# Function: dir_to_hash
#   read dir and shows as hash path=>file_content
#
# Parameters:
#   $dir - Str - path to dir
#
# Returns:
#   %hash - Hash
sub dir_to_hash {
  my ($dir) = @_;
  my %hash;
  local $/;
  
  for my $f (<$dir/*>) {
    if (-d $f) {
      %hash = (%hash, dir_to_hash("$f"));
    }
    elsif (-f $f) {
      open(my $fh, '<utf8', $f) or die "Can't read $f";
      my $data = <$fh>;
      close $fh;
      %hash = (%hash, "$f" => $data);
    }
  }
  return %hash;
}