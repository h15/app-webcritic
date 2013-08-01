# Class: App::webcritic::Critic::ParseStrategy::StrategyInterface
#  Interface for parsing strategies.

package App::webcritic::Critic::ParseStrategy::StrategyInterface;
use Pony::Object -abstract;
  
  # Method: add
  #   add links into strategy
  # Parameters:
  #   $list - Array - list of links, which we should add.
  sub add : Abstract;
  
  # Method: pull
  #   pull from this collection link
  # Returns:
  #   App::webcritic::Critic::Site::Page::Link
  sub pull : Abstract;
  
  # Method: mark_as_visited
  #   Remember that this page / link is visited / indexed
  #
  # Parameters:
  #   $page - App::webcritic::Critic::Site::Page::Link|App::webcritic::Critic::Site::Page
  sub mark_as_visited : Abstract;
  
  # Method: is_visited
  #   Check page / link
  #
  # Parameters:
  #   $page - App::webcritic::Critic::Site::Page::Link|App::webcritic::Critic::Site::Page
  #
  # Returns:
  #   Boolean
  sub is_visited : Abstract;
  
1;

__END__

=pod

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Georgy Bazhukov.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
