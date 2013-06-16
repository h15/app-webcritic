# Class: App::webcritic::Critic::UserAgent::Factory
#   UserAgent factory.
#   Singleton.
package App::webcritic::Critic::UserAgent::Factory;
use Pony::Object qw/-singleton/;
use Module::Load;
  
  protected default_ua_adaptor =>
    'App::webcritic::Critic::UserAgent::Adaptor::Mojo';
  protected 'ua_adaptor';
  
  # Method: init
  #   Constructor
  #
  # Parameters:
  #   $this->ua_adaptor - Str|undef - package of adaptor
  sub init : Public
    {
      my $this = shift;
      $this->ua_adaptor = shift || $this->default_ua_adaptor;
    }
  
  # Method: set_default_ua
  #   setter for default_ua_adaptor
  #
  # Parameters:
  #   $this->default_ua_adaptor - Str - package of adaptor
  sub set_default_ua : Public
    {
      my $this = shift;
      $this->default_ua_adaptor = shift;
    }
  
  # Method: get_ua
  #   Create UserAgent
  #
  # Parameters:
  #   @_ - adaptor's constructor params
  #
  # Returns:
  #   App::webcritic::Critic::UserAgent::Interface
  sub get_ua : Public
    {
      my $this = shift;
      load $this->ua_adaptor;
      return $this->ua_adaptor->new(@_);
    }
  
1;

__END__

=pod

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Georgy Bazhukov.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
