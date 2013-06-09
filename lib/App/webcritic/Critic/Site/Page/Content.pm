# Class: App::webcritic::Critic::Site::Page::Content
#   Page's content
package App::webcritic::Critic::Site::Page::Content;
use Pony::Object;
  
  protected 'data';
  
  # Method: init
  #   Constructor
  #
  # Parameters:
  #   $this->data - Str - Page content
  sub init : Public
    {
      my $this = shift;
      $this->data = shift;
    }
  
  # Method: get_data
  #   getter for data
  #
  # Returns:
  #   $this->data - Str
  sub get_data : Public
    {
      my $this = shift;
      return $this->data;
    }
  
1;

__END__

=pod

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Georgy Bazhukov.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
