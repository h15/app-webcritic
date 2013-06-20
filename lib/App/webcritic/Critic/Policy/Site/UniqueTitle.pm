# Class: App::webcritic::Critic::Policy::Site::UniqueTitle
#   Site's policy: does all titles are uniq.
# Extends:
#   App::webcritic::Critic::Policy::Site::Interface
#   App::webcritic::Critic::Logger
package App::webcritic::Critic::Policy::Site::UniqueTitle;
use Pony::Object qw/App::webcritic::Critic::Policy::Site::Interface
                    App::webcritic::Critic::Logger/;
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
      my %title_to_page;
      $this->status = 0;
      
      for my $p (@{$this->site->get_page_list}) {
        next if not defined $p->get_content;
        next if $p->get_content->get_content eq '';
        
        $title_to_page{$p->get_content->get_title} = []
          unless exists $title_to_page{$p->get_content->get_title};
        push @{$title_to_page{$p->get_content->get_title}}, $p;
      }
      
      while (my($k, $v) = each %title_to_page) {
        if (@$v > 1) {
          $this->log_error("This pages has the same title (\"%s\"):\n\t%s",
            $k, join("\n\t", map {$_->get_url} @$v));
          $this->status == 0 ? $this->status = 1 : $this->status = 2;
        }
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
