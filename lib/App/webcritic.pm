# "That's a calculator. I ate it to gain its power."

package App::webcritic;
our $VERSION = '0.03';
use mop;

use App::webcritic::Log;
use App::webcritic::Web;

class Critic with App::webcritic::Log::Logger{
  has $!config;
  has $!site_list = [];
  
  method new($config) {
    $!config = $config;
    $opts = $!config->get_data()->{global}->{options};
    $self->set_log_level($opts->{log_level}) if $opts->{log_level};
    
    for my $site (@{$!config->get_data()->{site_list}}) {
      my %opts = %$opts;
      %opts = (%opts, %{$site->{options}}) if $site->{options};
      push @{$!site_list}, App::webcritic::Web::Site->new(
        $site->{url}, $site->{name}, \%opts);
    }
  }
  
  method parse_site_list {
    $_->parse()->check_policies() for @{$!site_list};
    return $self;
  }
  
  method run {
    $self->parse_site_list();
    return $self;
  }
  
  method print_result {
    $self->log_info("Result:");
    $self->log_info($_->name.' - '.$_->url) for @{$!site_list};
    return $self;
  }
}

1;

__END__

=pod

=head1 NAME

App::webcritic - A critic for web-sites.

=head1 OVERVIEW

webcritic provides script for site analitic. It runs for you site and check site
for some rules (planned).

=head1 USAGE

You can run webcritic from console line by this command:

  ./script/webcritic -c /path/to/config.json

The simple config describes site list, their urls (url for first page) and
local site name.

  {
    "site_list": [
      {
        "url": "http://127.0.0.1:3000",
        "name": "Test site"
      },
      {
        "url": "http://example.net",
        "name": "Example"
      }
    ]
  }

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Georgy Bazhukov.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut