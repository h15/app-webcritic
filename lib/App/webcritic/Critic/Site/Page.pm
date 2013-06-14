# Class: App::webcritic::Critic::Site::Page
#   Site's page
package App::webcritic::Critic::Site::Page;
use Pony::Object qw/App::webcritic::Critic::Logger/;
use App::webcritic::Critic::UserAgent::Factory;
use Time::HR;
  
  protected 'url';
  protected 'link';
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
      my $hrtime0 = gethrtime();
      
      my $ua = App::webcritic::Critic::UserAgent::Factory->new->get_ua($this);
      my ($code, $href_list) = $ua->get_page();
      $this->code = $code;
      $this->add_link_by_url($_) for @$href_list;
      
      if ($this->code == 200) {
        $this->log_info('[%d] %s', $this->code, $this->url);
      } else {
        $this->log_warn('[%d] %s', $this->code, $this->url);
      }
      
      my $hrtime1 = gethrtime();
      my $diff = ($hrtime1 - $hrtime0) / 1_000_000_000;
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
      my $url = shift;
      $this->log_debug('Add link '.$url);
      my $link = App::webcritic::Critic::Site::Page::Link->new(url => $url);
      push @{$this->link_list}, $link;
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
