# Class: App::webcritic::Critic::Log::Message
#   Message for user.
package App::webcritic::Critic::Log::Message;
use Pony::Object;
  
  protected 'level';
  protected 'format';
  protected 'params' => [];
  
  # Method: init
  #   Constructor
  #
  # Parameters:
  #   $this->level - Str - log level name
  #   $this->format - Str - message format
  #   $this->params - ArrayRef - array of params
  sub init : Public
    {
      my $this = shift;
      ($this->level, $this->format, $this->params) = @_;
    }
  
  # Method: get_level
  #   getter for log level
  #
  # Returns:
  #   $this->level - Str
  sub get_level : Public
    {
      my $this = shift;
      return $this->level;
    }
  
  # Method: get_format
  #   getter for format
  #
  # Returns:
  #   $this->format - Str
  sub get_format : Public
    {
      my $this = shift;
      return $this->format;
    }
  
  # Method: get_params
  #   getter for params
  #
  # Returns:
  #   $this->params - ArrayRef
  sub get_params : Public
    {
      my $this = shift;
      return $this->params;
    }
  
1;

__END__

=pod

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Georgy Bazhukov.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
