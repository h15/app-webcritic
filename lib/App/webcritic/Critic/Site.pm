# Class: App::webcritic::Critic::Site
#   Regular web site.
#
# Extends:
#   App::webcritic::Critic::Log::AbstractLogger
package App::webcritic::Critic::Site;
use Pony::Object qw/App::webcritic::Critic::Log::AbstractLogger :try/;
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
  protected 'page_by_url' => {};
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
      
      # Define log
      if (exists $this->options->{log}) {
        # Level
        $this->set_log_level($this->options->{log}->{level})
          if exists $this->options->{log}->{level};
        # Adaptor
        App::webcritic::Critic::Log::Factory->new
          ->set_default_log($this->options->{log}->{adaptor})->init
            if exists $this->options->{log}->{adaptor};
        # Options
        App::webcritic::Critic::Log::Factory->new
          ->set_log_adaptor_options($this->options->{log}->{options})
            if exists $this->options->{log}->{options};
        
        App::webcritic::Critic::Log::Factory->init;
        $this->set_log_adaptor(
          App::webcritic::Critic::Log::Factory->new->get_log()
        );
      }
      
      $this->name ||= 'Site ' . $this->url;
      ($this->domain) = ($this->url =~ m/\w+:\/\/([\w\d\-\.:]+)/); # port too
      
      $this->host = try {
        inet_aton $this->domain;
      } catch {
        '0.0.0.0';
      };
      
      my $link = App::webcritic::Critic::Site::Page::Link->new(url => $this->url);
      $this->first_page = App::webcritic::Critic::Site::Page->new($this, $link, 1);
      $this->add_page($this->first_page);
    }
  
  # Method: check_policies
  #   Check site policies
  sub check_policies : Public
    {
      my $this = shift;
      for my $policy (@{$this->options->{policies}->{site}}) {
        load $policy->{module};
        my $opts = (exists $policy->{options} ? $policy->{options} : {});
        my $p = $policy->{module}->new($opts);
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
  
  # Methed: set_log_level
  #   overrides Logger's method to set log level for pages
  #
  # Parameters:
  #   $new_level - Str - See $this->log_level_list
  sub set_log_level : Public
    {
      my $this = shift;
      $this->SUPER::set_log_level(@_);
      
      for my $p (@{$this->page_list}) {
        $p->set_log_level($this->get_log_level);
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
  
  # Method: get_page_list
  #
  # Returns: ArrayRef
  sub get_page_list : Public
    {
      my $this = shift;
      return $this->page_list;
    }
  
  # Method: parse
  #   parse site
  sub parse : Public
    {
      my $this = shift;
      $this->log_info('Start parse "'.$this->name.'"');
      my @pool = @{$this->page_list};
      
      while (my $page = pop @pool) {
        try {
          $page->parse();
          sleep($this->options->{sleep} || 0);
          
          for my $link (@{$page->get_link_list}) {
            my $new_page = App::webcritic::Critic::Site::Page->new($this, $link, $page->get_level + 1);
            
            next if $this->exist_page($new_page);
            next if $this->is_excluded($new_page);
            next if exists $this->options->{level_limit}
              && $this->options->{level_limit} < $new_page->get_level;
            
            $this->add_page($new_page);
            unshift @pool, $new_page;
            
            $new_page->check_policies();
          }
        } catch {
          say $@;
        };
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
  
  # Method: is_excluded
  #   Does this page excluded?
  #
  # Parameters:
  #   $page - App::webcritic::Critic::Site::Page
  #
  # Returns:
  #   1|0
  sub is_excluded : Public
    {
      my $this = shift;
      my $page = shift;
      
      for my $path (@{$this->options->{exclude}}) {
        return 1 if $page->get_url =~ /$path/;
      }
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
      $this->page_by_url->{$page->get_url} = $page;
    }
  
  # Method: get_page_by_url
  #   get page by url
  #
  # Parameters:
  #   $url - Str
  #
  # Returns:
  #   App::webcritic::Critic::Site::Page
  sub get_page_by_url : Public
    {
      my $this = shift;
      my $url = shift;
      return $this->page_by_url->{$url};
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
