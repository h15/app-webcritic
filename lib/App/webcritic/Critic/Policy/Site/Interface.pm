# Class: App::webcritic::Critic::Policy::Site::Interface
#   Interface for site's policies.
package App::webcritic::Critic::Policy::Site::Interface;
use Pony::Object -abstract;
  
  # Method: set_site
  #   setter for site
  #
  # Parameters:
  #   $this->site - App::webcritic::Critic::Site
  sub set_site : Public;
  
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
