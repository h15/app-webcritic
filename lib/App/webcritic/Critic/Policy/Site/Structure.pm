# Class: App::webcritic::Critic::Policy::Site::Structure
#   Site's policy: build site structure.
# Extends:
#   App::webcritic::Critic::Policy::Site::Interface
#   App::webcritic::Critic::Log::AbstractLogger
package App::webcritic::Critic::Policy::Site::Structure;
use Pony::Object qw/App::webcritic::Critic::Policy::Site::Interface
                    App::webcritic::Critic::Log::AbstractLogger/;
use App::webcritic::Critic::Site::Page;
use App::webcritic::Critic::Site::Page::Link;
  
  protected 'name';
  protected 'site';
  protected 'options';
  protected 'indexed' => {};
  
  # Var: status
  # | Inspect status.
  # |   0 - all fine
  # |   1 - something wrong
  # |   2 - too bad
  protected 'status';
  
  # Method: init
  #   Constructor
  sub init : Public
    {
      my $this = shift;
    }
  
  # Method: set_name
  #   setter for name
  #
  # Parameters:
  #   $this->name - Str
  sub set_name : Public
    {
      my $this = shift;
      $this->name = shift;
    }
  
  # Method: set_site
  #   setter for site property
  #
  # Parameters:
  #   $this->site - App::webcritic::Critic::Site
  sub set_site : Public
    {
      my $this = shift;
      $this->site = shift;
      $this->set_log_level($this->site->get_log_level);
      $this->log_info('Start NotFound policy');
    }
  
  # Method: get_status
  #   getter for status
  #
  # Returns:
  #   $this->status - Int - result
  sub get_status : Public
    {
      my $this = shift;
      return $this->status;
    }
  
  # Method: inspect
  #   inspect site
  sub inspect : Public
    {
      my $this = shift;
      my %struct;
      $this->status = 0;
      
      say dump {
        title => $this->site->get_first_page->get_content->get_title,
        url => $this->site->get_first_page->get_url,
        childs => $this->get_tree($this->site->get_first_page)
      };
    }
  
  # Method: get_tree
  #   get tree
  #
  # Parameters:
  #   $page - App::webcritic::Critic::Site::Page
  #
  # Returns:
  #   ArrayRef
  sub get_tree : Public
    {
      my $this = shift;
      my $page = shift;
      my @pages;
      
      for my $link (@{ $page->get_link_list }) {
        next if $this->indexed->{$link->get_url};
        my $page = $this->site->get_page_by_url($link->get_url);
        next if not defined $page->get_content;
        next if $page->get_content->get_content eq '';
        $this->indexed->{$link->get_url}++;
        
        push @pages, {
          title => $page->get_content->get_title,
          url => $page->get_url,
          childs => $this->get_tree($page)
        };
      }
      return \@pages;
    }
  
1;

__END__

=pod

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Georgy Bazhukov.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
