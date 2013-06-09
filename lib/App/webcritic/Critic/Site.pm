# Class: App::webcritic::Critic::Site
#   Regular web site
package App::webcritic::Critic::Site;
use Pony::Object;
use Socket;
use App::webcritic::Critic::Site::Page;
use App::webcritic::Critic::Site::Page::Link;

  protected 'name';
  protected 'url';
  protected 'domain';
  protected 'host';
  protected 'first_page';
  protected 'page_list' => [];
  
  # Method: init
  #   Constructor
  #
  # Parameters:
  #   $this->url - Str - url
  #   $this->name - Str - site's name (only in critic)
  sub init : Public
    {
      my $this = shift;
      ($this->url, $this->name) = @_;
      $this->name ||= 'Site ' . $this->url;
      ($this->domain) = ($this->url =~ m/\w+:\/\/([\w\d\-\.]+)/);
      $this->host = inet_ntoa $this->domain;
      
      my $link = App::webcritic::Critic::Site::Page::Link->new(url => $this->url);
      $this->first_page = App::webcritic::Critic::Site::Page->new($this, $link);
    }
  
  # Method: get_name
  #   getter name
  #
  # Returns:
  #   $this->name - Str
  sub get_name : Public
    {
      my $this = shift;
      return $this->name;
    }
  
  # Method: get_domain
  #   getter domain
  #
  # Returns:
  #   $this->domain - Str
  sub get_domain : Public
    {
      my $this = shift;
      return $this->domain;
    }
  
  # Method: get_host
  #   getter host
  #
  # Returns:
  #   $this->host - Str
  sub get_host : Public
    {
      my $this = shift;
      return $this->host;
    }
  
  
  # Method: get_first_page
  #   getter first_page
  #
  # Returns:
  #   $this->first_page - Str
  sub get_first_page : Public
    {
      my $this = shift;
      return $this->first_page;
    }

1;

__END__

=pod

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Georgy Bazhukov.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
