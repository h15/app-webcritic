# Class: App::webcritic::Critic::Policy::Page::YandexMetrica
#   Site's policy: does site uses YandexMetrica.
# Extends:
#   App::webcritic::Critic::Policy::Site::Interface
#   App::webcritic::Critic::Log::AbstractLogger
package App::webcritic::Critic::Policy::Page::YandexMetrica;
use Pony::Object qw/App::webcritic::Critic::Policy::Page::Interface
                    App::webcritic::Critic::Log::AbstractLogger/;
  
  protected 'name';
  protected 'page';
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
  
  # Method: set_page
  #   setter for page property
  #
  # Parameters:
  #   $this->page - App::webcritic::Critic::Site::Page
  sub set_page : Public
    {
      my $this = shift;
      $this->page = shift;
      $this->set_log_level($this->page->get_log_level);
      $this->log_info('Start YandexMetrica policy');
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
      my $text = $this->page->get_content ? $this->page->get_content->get_content : '';
      
      if ($text eq '') {
        $this->status = 1;
        return;
      }
      
      if ($this->is_valid($text)) {
        $this->status ||= 0;
      } else {
        $this->status = 2 if $this->status < 2;
      }
    }
  
  # Method: is_valid
  #   does yandex.metrica valid
  #   TODO: better implementation
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
      return 1 if $text =~ /\<!--\s*Yandex\.Metrika counter\s*--\>/i;
      return 0;
    }
  
1;

__END__

=pod

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Georgy Bazhukov.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
