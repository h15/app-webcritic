# Class: App::webcritic::Critic::Log::Adaptor::SimpleTerm
#   Simple log adaptor for terminals
#
# Implements: App::webcritic::Critic::Log::Interface
package App::webcritic::Critic::Log::Adaptor::SimpleTerm;
use Pony::Object qw/App::webcritic::Critic::Log::Interface/;
  
  protected message_list => [];
  
  # Method: render
  #   Render/store/etc message_list.
  sub render : Public
    {
      my $this = shift;
      my $res = *STDOUT;
      
      try { # don't fail
        for my $msg (@{$this->message_list}) {
          my $content = @{$msg->get_params} ?
            sprintf $msg->get_format, @{$msg->get_params} :
            sprintf $msg->get_format;
          printf $res "[%5s] %s\n", $msg->get_level, $content;
        }
      };
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
