package App::webcritic::Critic;
use Pony::Object -singleton => qw/App::webcritic::Critic::Logger/;
use App::webcritic::Critic::Site;
  
  protected 'config';
  protected 'site_list' => [];
  
  sub init : Public
    {
      my $this = shift;
      $this->config = shift;
      
      for my $site (@{$this->config->get_data->{site_list}}) {
        push @{$this->site_list}, App::webcritic::Critic::Site->new(
          $site->{url}, $site->{name},
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
      return $this;
    }
  
  sub print_result : Public
    {
      my $this = shift;
      $this->log_info("Result:");
      for my $site (@{$this->site_list}) {
        $this->log_info($site->get_name . ' - ' . $site->get_url);
      }
    }
  
1;