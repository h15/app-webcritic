# Class: App::webcritic::Critic::Policy::Page::Interface
#   Interface for page's policies.
package App::webcritic::Critic::Policy::Page::Interface;
use Pony::Object -abstract;
  
  # Method: set_page
  #   setter for page
  #
  # Parameters:
  #   $this->pagr - App::webcritic::Critic::Site::Page
  sub set_page : Public;
  
  # Method: get_status
  #   getter for status
  #
  # Returns:
  #   Int
  sub get_status : Public;
  
  # Method: inspect
  #   inspect site
  sub inspect : Public;
  
1;

__END__

=pod

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Georgy Bazhukov.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
