package App::webcritic::Critic::Site;
use Pony::Object;

  protected 'name';
  protected 'domain';
  protected 'host';
  protected 'first_page';
  protected 'page_list' => [];
  
  sub init : Public
    {
      my $this = shift;
    }
  
  sub get_name : Public
    {
      my $this = shift;
      return $this->name;
    }
  
  sub get_domain : Public
    {
      my $this = shift;
      return $this->domain;
    }
  
  sub get_host : Public
    {
      my $this = shift;
      return $this->host;
    }
  
  sub get_first_page : Public
    {
      my $this = shift;
      return $this->first_page;
    }

1;