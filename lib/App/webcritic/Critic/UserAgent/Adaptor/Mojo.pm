# Class: App::webcritic::Critic::UserAgent::Adaptor::Mojo
#   UserAgent adaptor. Using Mojo::UserAgent.
#
# Implements:
#   App::webcritic::Critic::UserAgent::Interface
package App::webcritic::Critic::UserAgent::Adaptor::Mojo;
use Pony::Object qw/App::webcritic::Critic::UserAgent::Interface
                    App::webcritic::Critic::Logger/;
use Mojo::UserAgent;
  
  protected 'page';
  protected static 'scheme_list' => [qw/http https ftp/];
  protected static 'url_chars' => '\w\d\.\\\/+\-_%~#&?:';
  
  # Method: init
  #   Constructor
  #
  # Parameters:
  #   $this->page - App::webcritic::Site::Page
  sub init : Public
    {
      my $this = shift;
      $this->page = shift;
    }
  
  # Method: get_page
  #   get parsed page content.
  #
  # Returns:
  #   $code - Int - HTTP code
  #   $content - Str - Page content
  #   \@a_href_list - ArrayRef - urls from a[href]
  #   \@img_src_list - ArrayRef - urls from img[src]
  #   \@link_href_list - ArrayRef - urls from link[href]
  #   \@script_src_list - ArrayRef - urls from script[src]
  #   \@undef_list - ArrayRef - url from other
  sub get_page : Public
    {
      my $this = shift;
      my @pool = ($this->page->get_url);
      my $res = Mojo::UserAgent->new->get($this->page->get_url)->res;
      my $code = $res->{code};
      
      if (exists $res->{error} && @{$res->{error}}) {
        $this->log_error("%s:\n\t%s", $this->page->get_url, join "\n\t", @{$res->{error}});
        return $code, '', [], [], [] ,[], [];
      }
      
      my (%a_href_list, %img_src_list, %link_href_list,
          %script_src_list, %undef_list);
      
      # Skip by content-type
      if ($res->content->{headers}->{headers}->{'content-type'}[0][0] !~ /(?:text|html)/) {
        $this->log_debug('%s looks like non-text/html document', $this->page->get_url);
        return $code, '', [keys %a_href_list], [keys %img_src_list],
          [keys %link_href_list], [keys %script_src_list], [keys %undef_list];
      }
      
      # text/html/etc
      my $content = $res->content->{asset}->{content} || '';
      
      # a href
      $res->dom->find('a')->map(sub {
        my $href = $_[0]->{href} || return;
        $href = $this->get_link($href) || return;
        $a_href_list{$href}++;
      });
      
      # img src
      $res->dom->find('img')->map(sub {
        my $src = $_[0]->{src} || return;
        $src = $this->get_link($src) || return;
        $img_src_list{$src}++;
      });
      
      # link href
      $res->dom->find('link')->map(sub {
        my $src = $_[0]->{href} || return;
        $src = $this->get_link($src) || return;
        $link_href_list{$src}++;
      });
      
      # script src
      $res->dom->find('script')->map(sub {
        my $src = $_[0]->{href} || return;
        $src = $this->get_link($src) || return;
        $script_src_list{$src}++;
      });
      
      my $schemes = join '|', @{$this->scheme_list};
      my $url_chars = $this->url_chars;
      my $abs_url_re = qr/(?:$schemes):\/\/[$url_chars]*/;
      my $rel_url_re = qr/[$url_chars]+/;
      
      # undef
      
      # Only for css.
      # TODO: define type of document.
      if (my @url = ($content =~ /url\s*\(\s*["']?\s*($rel_url_re|$abs_url_re)\s*["']?\s*\)/gi)) {
        for my $url (@url) {
          next if exists $a_href_list{$url} || exists $img_src_list{$url} ||
            exists $link_href_list{$url} || exists $script_src_list{$url};
          $url = $this->get_link($url) || next;
          $undef_list{$url}++;
        }
      }
      
      if (my @url = ($content =~ /($abs_url_re)/gi)) {
        for my $url (@url) {
          next if exists $a_href_list{$url} || exists $img_src_list{$url} ||
            exists $link_href_list{$url} || exists $script_src_list{$url};
          $url = $this->get_link($url) || next;
          $undef_list{$url}++;
        }
      }
      
      return $code, $content, [keys %a_href_list], [keys %img_src_list],
        [keys %link_href_list], [keys %script_src_list], [keys %undef_list];
    }
  
  # Method: get_link
  #   create absolute link from link for this domain
  #
  # Parameters:
  #   $href - Str - uri|url
  #
  # Returns:
  #   $href - Str|undef - url
  sub get_link : Protected
    {
      my $this = shift;
      my ($href) = @_;
      $href = [split /#/, $href]->[0];
      return unless defined $href;
      
      my $schemes = join '|', @{$this->scheme_list};
      my $url_chars = $this->url_chars;
      my $abs_url_re = qr/(?:$schemes):\/\/[$url_chars]*/;
      
      if ($href =~ /^$abs_url_re/) {}
      elsif ($href =~ /^mailto:/) { return }     # skip
      elsif ($href =~ /^javascript:/) { return } # skip
      # /hello.jpg
      elsif ($href =~ /^\//) {
        $href = $this->page->get_scheme."://".$this->page->get_site->get_domain.$href;
      }
      # ./hello.jpg
      elsif ($href =~ /^\.\//) {
        $href = substr $href, 2;
        my @parts = split /\//, $this->page->get_url, -1;
        pop @parts;
        push @parts, $href;
        $href = join '/', @parts;
      }
      # ../hello.jpg
      elsif ($href =~ /^\.\.\//) {
        $href = substr $href, 3;
        my @parts = split /\//, $this->page->get_url, -1;
        pop @parts;
        pop @parts;
        push @parts, $href;
        $href = join '/', @parts;
      }
      # hello.jpg
      else {
        my @parts = split /\//, $this->page->get_url, -1;
        pop @parts;
        push @parts, $href;
        $href = join '/', @parts;
      }
      
      my $domain = $this->page->get_site->get_domain;
      return if $href !~ /$domain/;
      return $href;
    }
  
1;

__END__

=pod

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Georgy Bazhukov.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
