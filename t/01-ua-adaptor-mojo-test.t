#! /usr/bin/perl

use lib './lib', './t', '../lib', '../t';

use utf8;
use strict;
use warnings;
use feature ':5.10';
use Data::Dumper;
use My::Util qw(dir_to_hash);
use Test::More tests => 6;

use Pony::Object ':noobject';
BEGIN { $Pony::Object::DEFAULT->{''}->{withExceptions} = 1 }

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

{ # Check simple html file.
  my $link = App::webcritic::Critic::Site::Page::Link->new(url => 'http://webcritic/index.html');
  my $page = App::webcritic::Critic::Site::Page->new($site, $link);
  my $ua = App::webcritic::Critic::UserAgent::Adaptor::MojoTest->new($page, \%pages); # fake is here
  my ($code, $title, $content, $a_href_list, $img_src_list, $link_href_list,
      $script_src_list, $undef_list) = $ua->get_page($page);
  
  ok($code == 200, 'Page found');
  ok(grep({$_ eq $site_root.'css/style.css'} @$link_href_list), 'Find stylesheet');
  ok(grep({$_ eq $site_root.'catalog'} @$a_href_list), 'Find href');
  ok(!grep({$_ =~ qr#\.\./\.\./#} @$a_href_list), 'Ignore ../.. links');
}

{ # Check css file
  my $link = App::webcritic::Critic::Site::Page::Link->new(url => 'http://webcritic/css/style.css');
  my $page = App::webcritic::Critic::Site::Page->new($site, $link);
  my $ua = App::webcritic::Critic::UserAgent::Adaptor::MojoTest->new($page, \%pages); # fake is here
  my ($code, $title, $content, $a_href_list, $img_src_list, $link_href_list,
      $script_src_list, $undef_list) = $ua->get_page($page);
  
  ok($code == 200, 'Stylesheet found');
  ok(grep({$_ eq $site_root.'img/bg.png'} @$undef_list), 'Find url to pic in stylesheet');
}
