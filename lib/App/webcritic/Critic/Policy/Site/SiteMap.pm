# Class: App::webcritic::Critic::Policy::Site::SiteMap
#   Site's policy: does sitemap.xml exist and valid.
# Extends:
#   App::webcritic::Critic::Policy::Site::Interface
#   App::webcritic::Critic::Log::AbstractLogger
package App::webcritic::Critic::Policy::Site::SiteMap;
use Pony::Object qw/App::webcritic::Critic::Policy::Site::Interface
                    App::webcritic::Critic::Log::AbstractLogger/;
use Pony::Object::Throwable;
use App::webcritic::Critic::Site::Page;
use App::webcritic::Critic::Site::Page::Link;
use App::webcritic;
  
  protected 'name';
  protected 'site';
  protected 'options';
  
  # Var: status
  # | Inspect status.
  # |   0 - all fine
  # |   1 - something wrong
  # |   2 - too bad
  protected 'status' => 0;
  
  # Method: init
  #   Constructor
  #
  # Parameters:
  #   $this->options - policy options
  sub init : Public
    {
      my $this = shift;
      $this->options = shift || {};
      # check options
      unless (exists $this->options->{url}) {
        throw Pony::Object::Throwable(__PACKAGE__." required 'url' option.");
      }
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
      $this->log_info('Start SiteMap policy');
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
      my $link = App::webcritic::Critic::Site::Page::Link
        ->new(url => $fp->get_scheme.'://'.$this->site->get_domain.$this->options->{url});
      my $page = App::webcritic::Critic::Site::Page->new($this->site, $link);
      $page->set_log_level('off');
      $page->parse;
      
      if ($page->get_code == 200) {
        $this->status ||= 0;
      } else {
        $this->status = 2 if $this->status < 2;
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
