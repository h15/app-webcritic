# Class: App::webcritic::Critic::Log::Adaptor::SimpleTerm
#   Simple log adaptor for terminals
#
# Implements: App::webcritic::Critic::Log::Interface
package App::webcritic::Critic::Log::Adaptor::SimpleTerm;
use Pony::Object qw/:try App::webcritic::Critic::Log::Interface/;
  
  protected message_list => [];
  protected static 'path';
  
  # Method: init
  #   Constructor. Open target file if exists.
  #
  # Parameters:
  #   %params - Hash. Possible keys: "path" - path to file.
  sub init : Public
    {
      my $this = shift;
      my %params = @_;
      
      if (exists $params{path} && !$this->path) {
        $this->path = $params{path};
        if (-d $this->path) {
          my ($s, $m, $h, $d, $M, $y) = map {$_ < 10 ? "0$_" : $_} localtime;
          
          $y += 1900;
          $M += 1;
          $M = $M < 10 ? "0$M" : $M;
          
          $this->path .= "/$y-$M-${d}_$h-$m-$s.log";
          
          open(my $fh, '>>', $this->path) or die "Can't write to ".$this->path;
          close $fh;
        }
      }
    }
  
  # Method: render
  #   Render/store/etc message_list.
  sub render : Public
    {
      my $this = shift;
      my $res;
      
      if (-w $this->path) {
        open($res, '>>', $this->path);
      } else {
        $res = *STDOUT;
      }
      
      try { # don't fail
        for my $msg (@{$this->message_list}) {
          my $content = @{$msg->get_params} ?
            sprintf $msg->get_format, @{$msg->get_params} :
            sprintf $msg->get_format;
          printf $res "[%5s] %s\n", $msg->get_level, $content;
        }
      };
      
      close $res if -w $this->path;
    }
  
  # Method: add_message
  #   Add message into message_list.
  #
  # Parameters:
  #   $message - App::webcritic::Critic::Log::Message
  sub add_message : Public
    {
      my $this = shift;
      push @{$this->message_list}, @_;
      $this->render;
    }
  
1;

__END__

=pod

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Georgy Bazhukov.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
