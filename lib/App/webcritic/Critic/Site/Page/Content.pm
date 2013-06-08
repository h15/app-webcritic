package App::webcritic::Critic::Site::Page::Content;
use Pony::Object;

  protected 'data';
  
  sub get_data : Public
    {
      my $this = shift;
      return $this->data;
    }

1;