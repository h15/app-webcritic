package App::webcritic::Critic::WebServer::Test;
use Mojolicious::Lite;
use Pony::Object;
use Mojo::IOLoop;
use Mojo::Server::Daemon;
  
  protected 'pages';
  
  sub init : Public
    {
      my $this = shift;
      $this->pages = shift;
    }
  
  sub run_server : Public
    {
      my $this = shift;
      my $daemon = Mojo::Server::Daemon
        ->new(app => app, listen => ["http://*:17357"]);
      
      get ['/', '*url'] => sub {
        my $self = shift;
        my $url = $self->param('url') || 'index.html';
        
        return $self->render(template => 'my_not_found', code => 404) unless exists $this->pages->{$url};
        return $self->render(text => $this->pages->{$url});
      };
      
      $daemon->run;
    }
  
1;

__DATA__
@@ not_found.html.ep
<h1>Not Found</h1>

@@ my_not_found.html.ep
<h1>Not Found*</h1>