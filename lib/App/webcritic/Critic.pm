# Class: App::webcritic::Critic
#   The Critic.
#   Singleton.
#
# Extends:
#   App::webcritic::Critic::Log::AbstractLogger
package App::webcritic::Critic;
use Pony::Object -singleton => qw/App::webcritic::Critic::Log::AbstractLogger/;
use App::webcritic::Critic::Site;
  
  protected 'config';
  protected 'site_list' => [];
  
  # Method: init
  #   Constructor
  #
  # Parameters:
  #   $this->config - App::webcritic::Config
  sub init : Public
    {
      my $this = shift;
      $this->config = shift;
      my $glob_opts = $this->config->get_data->{global}->{options};
      
      $this->set_log_level($glob_opts->{log_level}) if exists $glob_opts->{log_level};
      
      # Create sites
      for my $site (@{$this->config->get_data->{site_list}}) {
        my %options = %$glob_opts;
        %options = (%options, %{$site->{options}}) if exists $site->{options};
        
        push @{$this->site_list}, App::webcritic::Critic::Site->new(
          $site->{url}, $site->{name}, \%options
        );
      }
    }
  
  # Method: parse_site_list
  #   parse site list
  sub parse_site_list : Public
    {
      my $this = shift;
      
      for my $site (@{$this->site_list}) {
        $site->parse();
        $site->check_policies();
      }
    }
  
  # Method: run
  #   run critic
  #
  # Returns:
  #   $this - App::webcritic::Critic
  sub run : Public
    {
      my $this = shift;
      $this->parse_site_list();
      return $this;
    }
  
  # Method: print_result
  #   show result of critic's work
  #
  # Returns:
  #   $this - App::webcritic::Critic
  sub print_result : Public
    {
      my $this = shift;
      $this->log_info("Result:");
      for my $site (@{$this->site_list}) {
        $this->log_info($site->get_name . ' - ' . $site->get_url);
      }
      return $this;
    }
  
1;

__END__

=pod

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Georgy Bazhukov.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
