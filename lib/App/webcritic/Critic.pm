package App::webcritic::Critic;
use Pony::Object -singleton;
use App::webcritic::Critic::Site;
  
  protected 'config';
  protected 'site_list' => [];
  
  sub init : Public
    {
      my $this = shift;
      $this->config = shift;
      
      for my $site_name (keys %{$this->config->data}) {
        push @{ $this->site_list }, App::webcritic::Critic::Site->new();
      }
    }
  
  sub parse_site_list : Public
    {
      
    }
  
1;