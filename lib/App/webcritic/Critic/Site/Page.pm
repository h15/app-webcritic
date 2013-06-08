package App::webcritic::Critic::Site::Page;
use Pony::Object qw/App::webcritic::Critic::Logger/;
  
  protected 'url';
  protected 'site';
  protected 'scheme';
  protected 'visited' => 0;
  protected 'code';
  protected 'time';
  protected 'last_modify';
  protected 'link_list' => [];
  protected 'level';
  
  sub init : Public
    {
      my $this = shift;
      ($this->site, $this->url) = @_;
    }
  
  sub parse : Public
    {
      my $this = shift;
      my @pool = ($this->url);
      
      
    }
  
  sub is_visited : Public
    {
      my $this = shift;
      return 1 if $this->is_visited;
      return 0;
    }
  
  sub get_url : Public
    {
      my $this = shift;
      return $this->url;
    }
  
  sub get_scheme : Public
    {
      my $this = shift;
      return $this->scheme;
    }
  
  sub get_code : Public
    {
      my $this = shift;
      return $this->code;
    }
  
  sub get_time : Public
    {
      my $this = shift;
      return $this->time;
    }

1;