# Class: App::webcritic::Critic::Site::Page::Content
#   Page's content
package App::webcritic::Critic::Site::Page::Content;
use Pony::Object;
  
  protected 'code' => 0;
  protected 'title' => '';
  protected 'content' => '';
  
  # Method: init
  #   Constructor
  #
  # Parameters:
  #   $this->code - Int - HTTP code
  #   $this->title - Str - Page title
  #   $this->content - Str - Page content
  sub init : Public
    {
      my $this = shift;
      ($this->code, $this->title, $this->content) = @_;
    }
  
  # Method: get_content
  #   getter for content
  #
  # Returns:
  #   $this->content - Str
  sub get_content : Public
    {
      my $this = shift;
      return $this->content;
    }
  
  # Method: get_title
  #   getter for title
  #
  # Returns:
  #   $this->title - Str
  sub get_title : Public
    {
      my $this = shift;
      return $this->title;
    }
  
  # Method: get_code
  #   Get HTTP code
  #
  # Returns:
  #   $this->code - Int - HTTP code
  sub get_code : Public
    {
      my $this = shift;
      return $this->code;
    }
  
1;

__END__

=pod

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Georgy Bazhukov.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
