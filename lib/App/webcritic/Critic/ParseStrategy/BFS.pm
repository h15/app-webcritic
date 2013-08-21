# Class: App::webcritic::Critic::ParseStrategy::BFS
#   Breadth-first search (BFS) strategy for scanning
# Implements:
#   App::webcritic::Critic::ParseStrategy::StrategyInterface

package App::webcritic::Critic::ParseStrategy::BFS;
use Pony::Object qw/App::webcritic::Critic::ParseStrategy::StrategyInterface/;
use Pony::Object::Throwable;
use Digest::MD5 'md5_hex';
  
  protected queue => [];
  protected visited_list_by_url  => {};
  protected visited_list_by_hash => {};
  
  # Method: add
  #   add links into strategy
  # Parameters:
  #   $list - Array - list of links, which we should add.
  sub add : Public
    {
      my $this = shift;
      my @list = @_;
      
      for my $link (@list) {
        next if $this->is_visited($link);
        push @{$this->queue}, $link;
      }
    }
  
  # Method: pull
  #   pull from this collection link
  # Returns:
  #   App::webcritic::Critic::Site::Page::Link
  sub pull : Public
    {
      my $this = shift;
      return shift(@{$this->queue});
    }
  
  # Method: mark_as_visited
  #   Remember that this page / link is visited / indexed
  #
  # Parameters:
  #   $page - App::webcritic::Critic::Site::Page::Link|App::webcritic::Critic::Site::Page
  sub mark_as_visited : Public
    {
      my $this = shift;
      my $page = shift;
      
      if ($page->isa('App::webcritic::Critic::Site::Page::Link')) {
        $this->visited_list_by_url->{$page->get_url} = 1;
      } elsif ($page->isa('App::webcritic::Critic::Site::Page')) {
        $this->visited_list_by_url->{$page->get_url} = 1;
        $this->visited_list_by_hash->{md5_hex($page->get_content->get_content)} = 1;
      } else {
        throw Pony::Object::Throwable('Invalid param');
      }
      
    }
  
  # Method: is_visited
  #   Check page / link
  #
  # Parameters:
  #   $page - App::webcritic::Critic::Site::Page::Link|App::webcritic::Critic::Site::Page
  #
  # Returns:
  #   Boolean
  sub is_visited : Public;
  
1;

__END__

=pod

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Georgy Bazhukov.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
