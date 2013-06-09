# Class: App::webcritic::Config
#   Application config
package App::webcritic::Config;
use Pony::Object;
use Pony::Object::Throwable;
use JSON::XS;
  
  protected 'data' => {};
  protected 'config' => {};
  private 'possible_configs' => {
    'config' => 'c',
    'url' => 'u',
  };
  
  # Method: init
  #   Constructor
  #
  # Parameters:
  #   $param - joined Array - @ARGV
  sub init : Public
    {
      my $this = shift;
      my $param = join ' ', @_;
      
      LOOP: {
        $this->add_param($1, $2), redo LOOP if $param =~ /\G\s*--([a-z\-]+)(?:=|\s+)(.+)(?:\s|$)/gcx;
        $this->add_param($1)    , redo LOOP if $param =~ /\G\s*--([a-z\-]+)             (?:\s|$)/gcx;
        $this->add_short($1, $2), redo LOOP if $param =~ /\G\s*- ([a-z])   (?:=|\s+)(.+)(?:\s|$)/gcx;
        $this->add_short($1)    , redo LOOP if $param =~ /\G\s*- ([a-z])                (?:\s|$)/gcx;
      }
      # TODO: error if param unknown.
      
      # Parse config file if exists.
      if (exists $this->config->{config} && $this->config->{config} ne '') {
        $this->parse_config($this->config->{config});
      }
      
    }
  
  # Method: add_param
  #   Add one parameter
  #
  # Parameters:
  #   $key - Str - param name
  #   $val - Str|Int(default=1) - value of config
  #
  # Throws: Pony::Object::Throwable
  sub add_param : Protected
    {
      my $this = shift;
      my ($key, $val) = (@_, 1);
      throw Pony::Object::Throwable("Invalid key $key")
        unless exists $this->possible_configs->{$key};
      $this->config->{$key} = $val;
    }
  
  # Method: add_short
  #   Add one param by their short name
  #
  # Parameters:
  #   $key - Str - param name
  #   $val - Str|Int(default=1) - value of config
  #
  # Throws: Pony::Object::Throwable
  sub add_short : Protected
    {
      my $this = shift;
      my ($key, $val) = (@_, 1);
      my %short = reverse %{$this->possible_configs};
      throw Pony::Object::Throwable("Invalid key $key")
        unless exists $short{$key};
      $key = $short{$key};
      $this->config->{$key} = $val;
    }
  
  # Method: get_config
  #   Get one config value by name.
  #
  # Parameters:
  #   $key - Str - param name
  # Returns:
  #   Str|Int|Undef - value of param
  sub get_config : Public
    {
      my $this = shift;
      my ($key) = @_;
      return undef unless exists $this->config->{$key};
      return $this->config->{$key};
    }
  
  # Method: get_data
  #   Get data
  #
  # Returns: HashRef
  sub get_data : Public
    {
      my $this = shift;
      return $this->data;
    }
  
  # Method: parse_config
  #   Parse config file
  #
  # Throws: Pony::Object::Throwable
  sub parse_config : Protected
    {
      my $this = shift;
      
      {# slurp config file
        local $/;
        open(my $fh, '<', $this->get_config('config'))
          or throw Pony::Object::Throwable('Can\'t read file ' . $this->get_config('config'));
        $this->data = JSON::XS->new->utf8->decode(<$fh>);
        close $fh;
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
