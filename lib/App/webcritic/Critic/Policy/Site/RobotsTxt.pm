# Class: App::webcritic::Critic::Policy::Site::RobotsTxt
#   Site's policy: does robots.txt exist and valid.
# Extends:
#   App::webcritic::Critic::Policy::Site::Interface
#   App::webcritic::Critic::Log::AbstractLogger
package App::webcritic::Critic::Policy::Site::RobotsTxt;
use Pony::Object qw/App::webcritic::Critic::Policy::Site::Interface
                    App::webcritic::Critic::Log::AbstractLogger/;
use App::webcritic::Critic::Site::Page;
use App::webcritic::Critic::Site::Page::Link;
use App::webcritic;
use WWW::RobotRules;
  
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
      $this->log_info('Start RobotsTxt policy');
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
        ->new(url => $fp->get_scheme.'://'.$this->site->get_domain.'/robots.txt');
      my $page = App::webcritic::Critic::Site::Page->new($this->site, $link);
      $page->set_log_level('off');
      $page->parse;
      
      my $text = $page->get_content->get_content;
      if ($this->is_valid($text)) {
        my $rules = WWW::RobotRules->new("webcritic/$App::webcritic::VERSION");
        $rules->parse($link->get_url, $text);
      }
      $this->site->add_page($page);
      $fp->add_link($link);
      
      if ($page->get_code == 200) {
        $this->status ||= 0;
      } else {
        $this->status = 2 if $this->status < 2;
      }
    }
  
  # Method: is_valid
  #   does robots.txt valid
  #
  # Parameters:
  #   $text - Str - file content
  #
  # Returns:
  #   0|1
  sub is_valid : Public
    {
      my $this = shift;
      my $text = shift;
      
      $text =~ s/\015\012/\012/g;
      for my $ln (split /[\012\015]/, $text) {
        next if $ln =~ /^\s*\#/; # comments
        next if $ln =~ /^\s*$/;  # empty lines
        next if $ln =~ /^\s*[\w\-]+\s*:\s*\S+\s*$/; # rules
        
        $this->status = 2;
        $this->log_error("Robots.txt isn't valid");
        return 0;
      }
      return 1;
    }
  
1;

__END__

=pod

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Georgy Bazhukov.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
