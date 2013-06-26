#! /usr/bin/perl

use lib './lib';
use lib './t';

use utf8;
use strict;
use warnings;
use feature ':5.10';
use Data::Dumper;
use Test::More tests => 3;

use App::webcritic::Critic::UserAgent::Adaptor::MojoTest;
use App::webcritic::Critic::Site::Page::Link;
use App::webcritic::Critic::Site::Page;
use App::webcritic::Critic::Site;

# Create page list
my $site_root = 'http://webcritic/';
my $dir = './t/00';
my %pages;
{
  my %tmp = dir_to_hash($dir);
  while (my ($k, $v) = each %tmp) {
    $k = substr $k, 1 + length $dir;
    $pages{$site_root.$k} = $v;
  }
}

# Create fake website
my $site = App::webcritic::Critic::Site->new('http://webcritic/index.html', 'test', {});
my $link = App::webcritic::Critic::Site::Page::Link->new(url => 'http://webcritic/index.html');
my $page = App::webcritic::Critic::Site::Page->new($site, $link);
my $ua = App::webcritic::Critic::UserAgent::Adaptor::MojoTest->new($page, \%pages); # fake is here
my ($code, $title, $content, $a_href_list, $img_src_list, $link_href_list,
    $script_src_list, $undef_list) = $ua->get_page($page);

ok($code == 200, 'Page found');
ok(grep({$_ eq $site_root.'css/style.css'} @$link_href_list), 'Find stylesheet');
ok(grep({$_ eq $site_root.'catalog'} @$a_href_list), 'Find href');

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