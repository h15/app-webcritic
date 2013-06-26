# Sheldon: I wouldn't tell you the secret. (pause) Shhhhh!!!!
# Leonard: What secret? Tell me the secret.
# Sheldon: Mom smokes in the car. Jesus is okay with it, but we can't tell dad.
# Leonard: Not that secret, the other secret.
# Sheldon: I'M BATMAN!!!! SHHHH!!!

# Class: App::webcritic::Critic::Logger
#   Abstract logger
package App::webcritic::Critic::Logger;
use Pony::Object -abstract;
use Pony::Object::Throwable;
use Term::ANSIColor;
  
  protected log_level => 0;
  protected static log_level_list => {
    debug => 00,
    info  => 20,
    warn  => 40,
    error => 60,
    fatal => 80,
    off   => 99,
  };
  protected static log_color => {
    debug => 'white',
    info  => 'bright_white',
    warn  => 'cyan',
    error => 'yellow',
    fatal => 'red',
  };
  
  # Method: set_log_level
  #   setter for log_level
  #
  # Parameters:
  #   $new_level - Str - See $this->log_level_list
  sub set_log_level : Public
    {
      my $this = shift;
      my $new_level = shift;
      
      throw Pony::Object::Throwable("Invalid log level \"$new_level\"")
        unless exists $this->log_level_list->{$new_level};
      
      $this->log_level = $this->log_level_list->{$new_level};
    }
  
  # Method: get_log_level
  #   getter for log_level
  #
  # Returns:
  #   Str - See $this->log_level_list
  sub get_log_level : Public
    {
      my $this = shift;
      my %list_log_level = reverse %{$this->log_level_list};
      
      throw Pony::Object::Throwable('Invalid log level "'.$this->log_level.'"')
        unless exists $list_log_level{$this->log_level};
      
      return $list_log_level{$this->log_level};
    }
  
  # Method: write_log
  #   Write messages into log
  #
  # Parameters:
  #   $level - log level name
  #   @content - Array - log info (sprintf)
  sub write_log : Public
    {
      my $this = shift;
      my ($level, @content) = @_;
      my $content = shift @content;
      $content = sprintf $content, @content if @content;
      
      my $res = *STDOUT;
      print color $this->log_color->{$level};
      printf $res "[%5s] %s\n", $level, $content;
      print color 'reset';
    }
  
  # Method: log_debug
  #   Log debug message
  #
  # Parameters:
  #   @content - Array - message for write_log
  sub log_debug : Public
    {
      my $this = shift;
      my @content = @_;
      return if $this->log_level_list->{debug} < $this->log_level;
      $this->write_log('debug', @content);
    }
  
  # Method: log_info
  #   Log info message
  #
  # Parameters:
  #   @content - Array - message for write_log
  sub log_info : Public
    {
      my $this = shift;
      my @content = @_;
      return if $this->log_level_list->{info} < $this->log_level;
      $this->write_log('info', @content);
    }
  
  # Method: log_warn
  #   Log warning message
  #
  # Parameters:
  #   @content - Array - message for write_log
  sub log_warn : Public
    {
      my $this = shift;
      my @content = @_;
      return if $this->log_level_list->{warn} < $this->log_level;
      $this->write_log('warn', @content);
    }
  
  # Method: log_error
  #   Log error message
  #
  # Parameters:
  #   @content - Array - message for write_log
  sub log_error : Public
    {
      my $this = shift;
      my @content = @_;
      return if $this->log_level_list->{error} < $this->log_level;
      $this->write_log('error', @content);
    }
  
  # Method: log_fatal
  #   Log fatal message
  #
  # Parameters:
  #   @content - Array - message for write_log
  sub log_fatal : Public
    {
      my $this = shift;
      my @content = @_;
      return if $this->log_level_list->{fatal} < $this->log_level;
      $this->write_log('fatal', @content);
    }
  
1;

__END__

=pod

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Georgy Bazhukov.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
