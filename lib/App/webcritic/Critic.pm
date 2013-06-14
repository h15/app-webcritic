package App::webcritic::Critic;
use Pony::Object -singleton => qw/App::webcritic::Critic::Logger/;
use App::webcritic::Critic::Site;
  
  protected 'config';
  protected 'site_list' => [];
  
  sub init : Public
    {
      my $this = shift;
      $this->config = shift;
      my $glob_opts = $this->config->get_data->{global}->{options};
      
      $this->set_log_level($glob_opts->{log_level}) if exists $glob_opts->{log_level};
      
      # Create sites
      for my $site (@{$this->config->get_data->{site_list}}) {
        my %options = %$glob_opts;
        %options = (%options, %{$site->{options}}) if exists $site->{options};
        
        push @{$this->site_list}, App::webcritic::Critic::Site->new(
          $site->{url}, $site->{name}, \%options
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