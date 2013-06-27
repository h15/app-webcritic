#! /usr/bin/perl

use lib './lib';
use lib './t';

use utf8;
use strict;
use warnings;
use feature ':5.10';
use Data::Dumper;
use My::Util qw(dir_to_hash);
use Test::More tests => 6;

use App::webcritic::Critic::UserAgent::Adaptor::MojoTest;
use App::webcritic::Critic::UserAgent::Factory;
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

# Predefine fake pages.
App::webcritic::Critic::UserAgent::Adaptor::MojoTest->new(undef, \%pages);
# Define default UA
App::webcritic::Critic::UserAgent::Factory->new
  ->set_default_ua('App::webcritic::Critic::UserAgent::Adaptor::MojoTest');

{ # Parse fake website
  my $site = App::webcritic::Critic::Site->new('http://webcritic/index.html', 'test', {});
  $site->parse();
  #$site->check_policies();
}