package App::webcritic::Critic::Site::Page::Link;
use Pony::Object;

my $types = {
  a_href => 1,
  img_src => 2,
  link_href => 3,
  source_src => 4,
};

  protected 'type';
  
  sub get_type : Public
    {
      my $this = shift;
      return $this->type;
    }

1;