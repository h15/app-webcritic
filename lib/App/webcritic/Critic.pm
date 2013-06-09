package App::webcritic::Critic;
use Pony::Object -singleton;
  
  protected 'config';
  protected 'site_list' => [];
  
  sub init : Public
    {
      my $this = shift;
      $this->config = shift;
      for my $site_conf (@{ $this->sites }) {
        
      }
    }
  
  sub parse_site_list : Public
    {
      
    }
  
1;