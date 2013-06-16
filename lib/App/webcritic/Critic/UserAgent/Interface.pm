# Class: App::webcritic::Critic::UserAgent::Interface
#   Interface for user agents.
package App::webcritic::Critic::UserAgent::Interface;
use Pony::Object -abstract;
  
  # Method: init
  #   Constructor
  #
  # Parameters:
  #   $this->page - App::webcritic::Site::Page
  sub init : Abstract;
  
  # Method: get_page
  #   get parsed page content.
  #
  # Returns:
  #   $code - Int - HTTP code
  #   $content - Str - Page content
  #   \@a_href_list - ArrayRef - urls from a[href]
  #   \@img_src_list - ArrayRef - urls from img[src]
  #   \@link_href_list - ArrayRef - urls from link[href]
  #   \@script_src_list - ArrayRef - urls from script[src]
  #   \@undef_list - ArrayRef - url from other
  sub get_page : Abstract;
  
1;

__END__

=pod

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Georgy Bazhukov.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
