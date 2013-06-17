# Class: App::webcritic::Critic::Policy::Site::RobotsTxt
#   Site's policy: does robots.txt exist and valid.
# Extends:
#   App::webcritic::Critic::Policy::Site::Interface
#   App::webcritic::Critic::Logger
package App::webcritic::Critic::Policy::Site::RobotsTxt;
use Pony::Object qw/App::webcritic::Critic::Policy::Site::Interface
                    App::webcritic::Critic::Logger/;
use App::webcritic::Critic::UserAgent::Factory;
use App::webcritic::Critic::Site::Page;
use App::webcritic::Critic::Site::Page::Link;
  
  protected 'name';
  protected 'site';
  protected 'options';
  
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
      $this->log_debug('Init RobotsTxt policy');
    }
  
  # Method: set_name
  #   setter for nam  e
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
      my $fp = $this->site->get_first_page;
      my $ua = App::webcritic::Critic::UserAgent::Factory->new->get_ua;
      my $link = App::webcritic::Critic::Site::Page::Link
        ->new($fp->get_scheme.'://'.$this->site->get_domain.'/robots.txt');
      my $page = App::webcritic::Critic::Site::Page->new($this->site, $link);
      $page->parse;
      $this->site->add_page($page);
      $fp->add_link($link);
      if ($page->get_code == 200) {
        $this->status = 0;
      } else {
        $this->status = 2;
      }
    }
  
1;

__END__

=pod

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Georgy Bazhukov.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
