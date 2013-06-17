# Class: App::webcritic::Critic::Site::Page
#   Site's page
#
# Extends:
#   App::webcritic::Critic::Logger
package App::webcritic::Critic::Site::Page;
use Pony::Object qw/App::webcritic::Critic::Logger/;
use App::webcritic::Critic::UserAgent::Factory;
use App::webcritic::Critic::Site::Page::Content;
use Time::HiRes qw/gettimeofday/;
  
  protected 'url';
  protected 'link';
  protected 'content';
  protected 'site';
  protected 'scheme';
  protected 'visited' => 0;
  protected 'code';
  protected 'time';
  protected 'last_modify';
  protected 'link_list' => [];
  protected 'level';
  
  # Method: init
  #   Constructor
  #
  # Parameters:
  #   $this->site - App::webcritic::Critic::Site
  #   $this->link - App::webcritic::Critic::Site::Page::Link
  sub init : Public
    {
      my $this = shift;
      ($this->site, $this->link) = @_;
      $this->url = $this->link->get_url;
      ($this->scheme) = ($this->url =~ /^(\w+):\/\//);
      
      $this->set_log_level($this->site->get_options->{log_level})
        if exists $this->site->get_options->{log_level};
    }
  
  # Method: parse
  #   parse page by user agent
  sub parse : Public
    {
      my $this = shift;
      
      $this->log_info('Looking for '.$this->url);
      my $hrtime0 = gettimeofday;
      
      my $ua = App::webcritic::Critic::UserAgent::Factory->new->get_ua($this);
      my ($code, $content, $a_href_list, $img_src_list,
          $link_href_list, $script_src_list, $undef_list) = $ua->get_page();
      
      $this->code = $code || 0;
      $this->content = App::webcritic::Critic::Site::Page::Content
        ->new($code, $content);
      
      $this->add_link_by_url($_, 'a_href')     for @$a_href_list;
      $this->add_link_by_url($_, 'img_src')    for @$img_src_list;
      $this->add_link_by_url($_, 'link_href')  for @$link_href_list;
      $this->add_link_by_url($_, 'script_src') for @$script_src_list;
      $this->add_link_by_url($_, 'undef')      for @$undef_list;
      
      if ($this->code == 200) {
        $this->log_info('[%d] %s', $this->code, $this->url);
      } else {
        $this->log_warn('[%d] %s', $this->code, $this->url);
      }
      
      my $hrtime1 = gettimeofday;
      my $diff = $hrtime1 - $hrtime0;
      $this->log_info($diff);
      $this->time = $diff;
    }
  
  # Method: add_link_by_url
  #   add to link_list by url
  #
  # Parameters:
  #   $url - Str
  sub add_link_by_url : Public
    {
      my $this = shift;
      my ($url, $type) = @_;
      return unless defined $url;
      $this->log_debug('Add link [%10s] %s', $type, $url);
      my $link = App::webcritic::Critic::Site::Page::Link->new(url => $url, type => $type);
      push @{$this->link_list}, $link;
    }
  
  # Method: add_link
  #   add link
  #
  # Parameters:
  #   $link - App::webcritic::Critic::Site::Page::Link
  sub add_link : Public
    {
      my $this = shift;
      my ($link) = @_;
      $this->log_debug('Add link [%10s] %s', $link->get_type, $this->url);
      push @{$this->link_list}, $link;
    }
  
  # Method: get_content
  #   getter for content
  #
  # Returns:
  #   App::webcritic::Critic::Site::Page::Content
  sub get_content : Public
    {
      my $this = shift;
      return $this->content;
    }
  
  # Method: get_link_list
  #   getter for link_list
  #
  # Returns:
  #   $this->link_list - ArrayRef
  sub get_link_list : Public
    {
      my $this = shift;
      return $this->link_list;
    }
  
  # Method: get_site
  #   Getter for site
  #
  # Returns:
  #   $this->site - App::webcritic::Critic::Site
  sub get_site : Public
    {
      my $this = shift;
      return $this->site;
    }
  
  # Method: is_visited
  #   does this page already visited
  #
  # Returns:
  #   1|0
  sub is_visited : Public
    {
      my $this = shift;
      return 1 if $this->is_visited;
      return 0;
    }
  
  # Method: get_url
  #   getter for url
  #
  # Returns:
  #   $this->url - Str
  sub get_url : Public
    {
      my $this = shift;
      return $this->url;
    }
  
  # Method: get_scheme
  #   getter for scheme
  #
  # Returns:
  #   $this->scheme - Str
  sub get_scheme : Public
    {
      my $this = shift;
      return $this->scheme;
    }
  
  # Method: get_code
  #   getter for code
  #
  # Returns:
  #   $this->code - Int
  sub get_code : Public
    {
      my $this = shift;
      return $this->code;
    }
  
  # Method: get_time
  #   getter for time
  #
  # Returns:
  #   $this->time - Float
  sub get_time : Public
    {
      my $this = shift;
      return $this->time;
    }
  
1;

__END__

=pod

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Georgy Bazhukov.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
