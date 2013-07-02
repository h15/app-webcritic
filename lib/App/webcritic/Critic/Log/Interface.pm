# Class: App::webcritic::Critic::Log::Interface
#   Interface for log adaptors.
package App::webcritic::Critic::Log::Interface;
use Pony::Object -abstract;
  
  # Method: render
  #   Render/store/etc log collection.
  sub render : Abstract;
  
  # Method: add_message
  #   Add message into collection.
  #
  # Parameters:
  #   $message - App::webcritic::Critic::Log::Message
  sub add_message : Abstract;
  
1;

__END__

=pod

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Georgy Bazhukov.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
