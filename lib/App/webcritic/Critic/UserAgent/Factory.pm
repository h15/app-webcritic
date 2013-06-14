package App::webcritic::Critic::UserAgent::Factory;
use Pony::Object qw/-singleton/;
use Module::Load;
  
  protected default_ua_adaptor =>
    'App::webcritic::Critic::UserAgent::Adaptor::Mojo';
  protected 'ua_adaptor';
  
  sub init : Public
    {
      my $this = shift;
      $this->ua_adaptor = $this->default_ua_adaptor;
    }
  
  sub get_ua : Public
    {
      my $this = shift;
      load $this->ua_adaptor;
      return $this->ua_adaptor->new(@_);
    }
  
1;