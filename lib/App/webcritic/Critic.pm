package App::webcritic::Critic;
use Pony::Object -singleton;
use Mojo::UserAgent;

  protected 'config';
  protected 'ua' => Mojo::UserAgent->new;
  
  sub init : Public
    {
      my $this = shift;
      $this->config = shift;
    }

1;