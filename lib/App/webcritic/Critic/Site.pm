# Class: App::webcritic::Critic::Site
#   Regular web site.
#
# Extends:
#   App::webcritic::Critic::Logger
package App::webcritic::Critic::Site;
use Pony::Object qw/App::webcritic::Critic::Logger/;
use Socket;
use Module::Load;
use App::webcritic::Critic::Site::Page;
use App::webcritic::Critic::Site::Page::Link;

  protected 'name';
  protected 'url';
  protected 'domain';
  protected 'host';
  protected 'first_page';
  protected 'page_list' => [];
  # Make 'exist_page' faster.
  protected 'exist_page_list' => {};
  protected 'options';
  
  # Method: init
  #   Constructor
  #
  # Parameters:
  #   $this->url - Str - url
  #   $this->name - Str - site's name (only in critic)
  #   $this->options - HashRef - site options
  sub init : Public
    {
      my $this = shift;
      ($this->url, $this->name, $this->options) = @_;
      $this->set_log_level($this->options->{log_level}) if exists $this->options->{log_level};
      
      $this->name ||= 'Site ' . $this->url;
      ($this->domain) = ($this->url =~ m/\w+:\/\/([\w\d\-\.:]+)/); # port too
      $this->host = inet_aton $this->domain;
      
      my $link = App::webcritic::Critic::Site::Page::Link->new(url => $this->url);
      $this->first_page = App::webcritic::Critic::Site::Page->new($this, $link);
      $this->add_page($this->first_page);
    }
  
  # Method: check_policies
  #   Check site policies
  sub check_policies : Public
    {
      my $this = shift;
      for my $policy (@{$this->options->{policies}->{site}}) {
        load $policy->{module};
        my $p = $policy->{module}->new;
        $p->set_name($policy->{name});
        $p->set_site($this);
        $p->inspect;
        
        my $status = $p->get_status;
        if ($status == 0) {
          $this->log_info('All fine at policy "%s"', $policy->{name});
        } elsif ($status == 1) {
          $this->log_warn('Something wrong at policy "%s"', $policy->{name});
        } elsif ($status == 2) {
          $this->log_error('Too bad at policy "%s"', $policy->{name});
        }
      }
    }
  
  # Method: get_options
  #   getter for options
  #
  # Returns:
  #   HashRef
  sub get_options : Public
    {
      my $this = shift;
      return $this->options;
    }
  
  # Method: parse
  #   parse site
  sub parse : Public
    {
      my $this = shift;
      $this->log_info('Start parse "'.$this->name.'"');
      my @pool = @{clone $this->page_list};
      
      while (my $page = pop @pool) {
        $page->parse();
        sleep $this->options->{sleep};
        for my $link (@{$page->get_link_list}) {
          my $new_page = App::webcritic::Critic::Site::Page->new($this, $link);
          next if $this->exist_page($new_page);
          $this->add_page($new_page);
          unshift @pool, $new_page;
        }
      }
      
      $this->log_info('"'.$this->name.'" parsed');
    }
  
  # Method: exist_page
  #   Does page already parsed?
  #
  # Parameters:
  #   $page - App::webcritic::Critic::Site::Page
  #
  # Returns:
  #   1|0
  sub exist_page : Public
    {
      my $this = shift;
      my $page = shift;
      return 1 if exists $this->exist_page_list->{$page->get_url};
      return 0;
    }
  
  # Method: add_page
  #   add page into page_list
  #
  # Parameters:
  #   $page - App::webcritic::Critic::Site::Page
  sub add_page : Public
    {
      my $this = shift;
      my $page = shift;
      push @{$this->page_list}, $page;
      $this->exist_page_list->{$page->get_url} = 1;
    }
  
  # Method: get_url
  #   getter for url
  #
  # Returns:
  #   $this->url - Str
  sub get_url : Public
    {
      my $this = shift;
      return $this->url;
    }
  
  # Method: get_name
  #   getter name
  #
  # Returns:
  #   $this->name - Str
  sub get_name : Public
    {
      my $this = shift;
      return $this->name;
    }
  
  # Method: get_domain
  #   getter domain
  #
  # Returns:
  #   $this->domain - Str
  sub get_domain : Public
    {
      my $this = shift;
      return $this->domain;
    }
  
  # Method: get_host
  #   getter host
  #
  # Returns:
  #   $this->host - Str
  sub get_host : Public
    {
      my $this = shift;
      return $this->host;
    }
  
  
  # Method: get_first_page
  #   getter first_page
  #
  # Returns:
  #   $this->first_page - Str
  sub get_first_page : Public
    {
      my $this = shift;
      return $this->first_page;
    }

1;

__END__

=pod

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Georgy Bazhukov.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
