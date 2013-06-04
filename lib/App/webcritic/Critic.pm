package App::webcritic::Critic;
use Pony::Object -singleton;

  protected 'config';
  
  sub init : Public
    {
      my $this = shift;
      $this->config = shift;
    }

1;