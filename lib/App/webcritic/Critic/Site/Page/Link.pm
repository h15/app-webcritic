package App::webcritic::Critic::Site::Page::Link;
use Pony::Object;

my $types = {
  a_href => 1,
  img_src => 2,
  link_href => 3,
  source_src => 4,
};

  protected 'type';
  protected 'url';
  protected 'text' => []; # Can be defined by many attributes.
  protected 'follow' => 0; # Rel=nofollow and others.
  protected 'page'; # App::webcritic::Critic::Site::Page for this link.
  
  sub init : Public
    {
      my $this = shift;
    }
  
  sub get_type : Public
    {
      my $this = shift;
      return $this->type;
    }

1;