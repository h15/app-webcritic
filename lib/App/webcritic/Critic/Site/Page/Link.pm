# Class: App::webcritic::Critic::Site::Page::Link
#   Link to some resource (like http document, css, js, etc)
package App::webcritic::Critic::Site::Page::Link;
use Pony::Object;
use Pony::Object::Throwable;
  
  # Var: $this->type_list
  #   List of valid types.
  #
  # Access: protected static
  protected static 'type_list' => {
    undef => undef,
    a_href => 1,
    img_src => 2,
    link_href => 3,
    source_src => 4,
  };
  
  # Var: $this->type
  #   Valid type. See $this->type_list.
  protected 'type' => undef;
  protected 'url';
  protected 'text' => []; # Can be defined by many attributes.
  protected 'follow' => 0; # Rel=nofollow and others.
  protected 'page'; # App::webcritic::Critic::Site::Page for this link.
  
  # Method: init
  #   Constructor
  #
  # Parameters:
  #   @_ - Hash - hash of params (type, url, text, follow)
  sub init : Public
    {
      my $this = shift;
      my %params = @_;
      ($this->url, $this->text, $this->follow) = @params{qw/url text follow/};
      my $type = $params{type};
      
      if (defined $type) {
        throw Pony::Object::Throwable("Invalid link type")
          unless exists $this->type_list->{$type};
        $this->type = $this->type_list->{$type};
      }
    }
  
  # Method: get_type
  #   get link type
  #
  # Returns:
  #   $this->type - Str|Undef
  sub get_type : Public
    {
      my $this = shift;
      throw Pony::Object::Throwable("Invalid link type")
        unless exists $this->type_list->{$this->type};
      return $this->type_list->{$this->type};
    }
  
  # Method: get_url
  #   get link's url
  #
  # Returns:
  #   $this->url - Str|Undef
  sub get_url : Public
    {
      my $this = shift;
      return $this->url;
    }
  
  # Method: get_text
  #   get text of link (alt, title, tag text, etc)
  #
  # Returns:
  #   $this->text - ArrayRef
  sub get_text : Public
    {
      my $this = shift;
      return $this->text;
    }
  
  # Method: is_follow
  #   Does this link opened for search engines (like Google or Yahoo)
  #
  # Returns:
  #   $this->follow - 1|0
  sub is_follow : Public
    {
      my $this = shift;
      return ($this->follow ? 1 : 0);
    }
  
  # Method: get_page
  #   Get link's page (if loaded)
  #
  # Returns:
  #   $this->page - App::webcritic::Critic::Site::Page|Undef
  sub get_page : Public
    {
      my $this = shift;
      return $this->page;
    }
  
  # Method: set_page
  #   Set page for link
  #
  # Parameters:
  #   $this->page - App::webcritic::Critic::Site::Page|Undef
  sub set_page : Public
    {
      my $this = shift;
      $this->page = shift;
    }
  
1;

__END__

=pod

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Georgy Bazhukov.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
