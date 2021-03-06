#! /usr/bin/perl

use lib './lib', './t', '../lib', '../t';

use utf8;
use strict;
use warnings;
use feature ':5.10';
use Data::Dumper;
use My::Util qw(dir_to_hash);
use Test::More tests => 10;

use Pony::Object ':noobject';
BEGIN { $Pony::Object::DEFAULT->{''}->{withExceptions} = 1 }

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
  ->set_default_ua('App::webcritic::Critic::UserAgent::Adaptor::MojoTest')
    ->init;

{ # Parse fake website
  my $site = App::webcritic::Critic::Site->new('http://webcritic/index.html', 'test', {});
  $site->set_log_level('off');
  $site->parse();
  # Walk the website
  ok($site->get_first_page->get_code == 200, 'First page looks 200');
  ok($site->get_first_page->get_url eq $site_root.'index.html', 'First page has right url');
  # link list
  ok(grep({$_->get_url eq $site_root} @{$site->get_first_page->get_link_list}), 'link list 1');
  ok(grep({$_->get_url eq $site_root.'about'} @{$site->get_first_page->get_link_list}), 'link list 2');
  ok(grep({$_->get_url eq $site_root.'catalog'} @{$site->get_first_page->get_link_list}), 'link list 3');
  ok(grep({$_->get_url eq $site_root.'css/style.css'} @{$site->get_first_page->get_link_list}), 'link list 4');
  # page list
  ok(grep({$_->get_url eq $site_root} @{$site->get_page_list}), 'page list 1');
  ok(grep({$_->get_url eq $site_root && $_->get_code == 404} @{$site->get_page_list}), '/ not found');
  ok(grep({$_->get_url eq $site_root.'css/style.css' && $_->get_code == 200} @{$site->get_page_list}), 'page list 2');
  ok(grep({$_->get_url eq $site_root.'img/bg.png' && $_->get_code == 200} @{$site->get_page_list}), 'page list 3');
}