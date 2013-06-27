# "That's a calculator. I ate it to gain its power."

package App::webcritic;
our $VERSION = '0.02';
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
