# Class: App::webcritic::Critic::UserAgent::Adaptor::MojoTest
#   UserAgent adaptor. Test Mojo::UserAgent adaptor.
#
# Extends:
#   App::webcritic::Critic::UserAgent::Adaptor::Mojo
package App::webcritic::Critic::UserAgent::Adaptor::MojoTest;
use Pony::Object qw/App::webcritic::Critic::UserAgent::Adaptor::Mojo/;
use Mojo::Message::Response;

  protected 'pages' => {};
  
  # Method: init
  #   Constructor
  #
  # Parameters:
  #   $this->page - App::webcritic::Site::Page
  #   $this->pages - HashRef
  sub init : Public
    {
      my $this = shift;
      $this->SUPER::init(shift);
      $this->pages = shift;
    }
  
  # Method: do_request
  #   request data from fake server
  #
  # Returns:
  #   $res
  sub do_request : Public
    {
      my $this = shift;
      my ($code, $content) = (0, '');
      
      if (exists $this->pages->{$this->page->get_url}) {
        $code = 200;
        $content = $this->pages->{$this->page->get_url};
      } else {
        $code = 404;
      }
      
      return $this->get_res($code, $content);
    }
  
  sub get_res : Public
    {
      my $this = shift;
      my ($code, $content) = @_;
      my $res = Mojo::Message::Response->new;
      $res->code($code);
      $res->headers->content_type('text/plain');
      $res->body($content);
      return $res;
    }
  
1;