package App::webcritic::Critic;
use Pony::Object -singleton;
use App::webcritic::Critic::Site;
  
  protected 'ua';
  protected 'config';
  protected 'site_list' => [];
  
  sub init : Public
    {
      my $this = shift;
      $this->config = shift;
      $this->ua = Mojo::UserAgent->new;
      
      for my $site_name (keys %{$this->config->get_data}) {
        push @{ $this->site_list }, App::webcritic::Critic::Site->new(
          $this->config->get_data->{$site_name}->{url},
          $this->config->get_data->{$site_name}->{name},
        );
      }
    }
  
  sub parse_site_list : Public
    {
      my $this = shift;
      
      for my $site (@{$this->site_list}) {
        $site->parse();
      }
    }
  
  sub run : Public
    {
      my $this = shift;
      $this->parse_site_list();
    }
  
  sub getUa : Public
    {
      my $this = shift;
      return $this->ua;
    }
  
1;