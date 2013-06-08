package App::webcritic::Critic::Resource::Mojo;
use Pony::Object qw/App::webcritic::Critic::Resource::Interface/;
  
  protected 'site';
  
  sub init : Public
    {
      my $this = shift;
      $this->site = shift;
    }

  sub get_page : Public
    {
      my $this = shift;
      my $page = $this->site->get_page_by_url(shift);
      my @pool = ($page->getUrl);
      
      while (@pool) {
        my $url = pop @pool;
        next if $this->site->get_page_by_url($url)->is_visited;
        
        $this->log_info("Looking for $url");
        my $res = $this->site->ua->get($url)->res;
        
        #$page->
        #$page{$url} = $res->code;
        
        
      }
    }

1;