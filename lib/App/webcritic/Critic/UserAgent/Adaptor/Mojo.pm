package App::webcritic::Critic::UserAgent::Adaptor::Mojo;
use Pony::Object qw/App::webcritic::Critic::UserAgent::Interface/;
use Mojo::UserAgent;
  
  protected 'page';
  
  sub init : Public
    {
      my $this = shift;
      $this->page = shift;
    }

  sub get_page : Public
    {
      my $this = shift;
      my @pool = ($this->page->get_url);
      
      my $res = Mojo::UserAgent->new->get($this->page->get_url)->res;
      my $code = $res->code;
      my @href_list;
      
      $res->dom->find('a')->map(sub {
          my $href = $_[0]->{href} or return;
          $href = [split /#/, $href]->[0];
          return unless defined $href;
          
          $href = $this->page->get_scheme."://".$this->page->get_site->get_domain.$href if $href =~ /^\//;
          my $domain = $this->page->get_site->get_domain;
          return if $href !~ /$domain/;
          
          push @href_list, $href;
      });
      
      return $code, \@href_list;
    }

1;