package App::webcritic::Critic::UserAgent::Adaptor::Mojo;
use Pony::Object qw/App::webcritic::Critic::UserAgent::Interface/;
use Mojo::UserAgent;
  
  protected 'page';
  
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
      my $code = $res->code;
      my (@a_href_list, @img_src_list, @link_href_list,
          @script_src_list, @undef_list);
      
      # a href
      $res->dom->find('a')->map(sub {
        my $href = $_[0]->{href} or return;
        $href = $this->get_link($href);
        push @a_href_list, $href;
      });
      
      # img src
      $res->dom->find('img')->map(sub {
        my $src = $_[0]->{src} or return;
        $src = $this->get_link($src);
        push @img_src_list, $src;
      });
      
      # link href
      $res->dom->find('link')->map(sub {
        my $src = $_[0]->{href} or return;
        $src = $this->get_link($src);
        push @link_href_list, $src;
      });
      
      # script src
      $res->dom->find('script')->map(sub {
        my $src = $_[0]->{href} or return;
        $src = $this->get_link($src);
        push @script_src_list, $src;
      });
      
      return $code, \@a_href_list, \@img_src_list,
        \@link_href_list, \@script_src_list, \@undef_list;
    }
  
  sub get_link : Protected
    {
      my $this = shift;
      my ($href) = @_;
      $href = [split /#/, $href]->[0];
      return unless defined $href;
      
      $href = $this->page->get_scheme."://".$this->page->get_site->get_domain.$href if $href =~ /^\//;
      my $domain = $this->page->get_site->get_domain;
      return if $href !~ /$domain/;
      return $href;
    }
  
1;