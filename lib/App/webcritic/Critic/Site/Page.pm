# Class: App::webcritic::Critic::Site::Page
#   Site's page
package App::webcritic::Critic::Site::Page;
use Pony::Object qw/App::webcritic::Critic::Logger/;
use Mojo::UserAgent;
  
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
    }
  
  sub parse : Public
    {
      my $this = shift;
      
      $this->log_info('Looking for '.$this->url);
      my $res = App::webcritic::Critic->new->getUa->get($this->url)->res;
      $this->code = $res->code;
      
      $res->dom->find('a')->map(sub {
          my $href = $_[0]->{href} or return;
          $href = [split /#/, $href]->[0];
          $href = $this->scheme."://".$this->domain.$href if $href =~ /^\//;
          my $domain = $this->domain;
          return if $href !~ /$domain/;
          $this->add_link_by_url($href);
      });
    }
  
  sub add_link_by_url : Public
    {
      my $this = shift;
      my $url = shift;
      my $link = App::webcritic::Critic::Site::Page::Link->new(url => $url);
      push @{$this->link_list}, $link;
    }
  
  sub get_link_list : Public
    {
      my $this = shift;
      return $this->link_list;
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
