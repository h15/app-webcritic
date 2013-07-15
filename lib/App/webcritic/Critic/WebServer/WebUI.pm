# Class: App::webcritic::Critic::WebServer::WebUI
#   Web user interface.
# Implements:
#   App::webcritic::Critic::Log::AbstractLogger
package App::webcritic::Critic::WebServer::WebUI;
use File::Spec::Functions 'catdir';
use Mojolicious::Lite;
use Pony::Object qw/:try App::webcritic::Critic::Log::AbstractLogger/;
use Mojo::IOLoop;
use Mojo::Server::Daemon;
use Pony::Object::Throwable;
  
  protected 'config';
  
  # Method: init
  #   Constructor
  #
  # Parameters:
  #   $this->config - HashRef
  sub init : Public
    {
      my $this = shift;
      $this->config = shift;
    }
  
  # Method: run_webui
  #   Web server starter.
  #   Simple Mojolicious::Lite server.
  sub run_webui : Public
    {
      my $this = shift;
      my $base = './data';
      push @{app->static->paths}, catdir($base, 'public');
      
      get '/' => sub {
        my $self = shift;
        
        $self->render('index');
      };
      
      get '/config' => sub {
        my $self = shift;
        my $list = $this->get_config_list('./config/local');
        
        my $conf = try {
          if ($self->session('config_name')) {
            open(my $fh, $self->session('config_name'))
              or throw Pony::Object::Throwable("Can't find config file ".$self->session('config_name'));
            local $/;
            my $data = <$fh>;
            close $fh;
            return $data;
          }
          return {};
        };
        
        return $self->stash(list => $list, conf => $conf)->render('config');
      };
      
      get '/css/bootstrap.min.css' => sub { shift->render('css/bootstrap.min.css'); };
      
      Mojo::Server::Daemon->new(app => app, listen => ["http://*:7357"])->run;
    }
  
  # Method: get_config_list
  #   Get config list
  #
  # Parameters:
  #   $path - Str - path to directory with configs
  #
  # Returns:
  #   \@list - ArrayRef - list of config files
  sub get_config_list : Public
    {
      my $this = shift;
      my $path = shift;
      my @list;
      
      for my $file (<$path/*>) {
        next unless -f $file;
        next if $file =~ /^\./;
        next if $file !~ /\.json$/;
        push @list, $file;
      }
      
      return \@list;
    }
  
1;

__DATA__

@@ layouts/default.html.ep
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <link href="/css/bootstrap.min.css" media="screen" rel="stylesheet" />
    <meta name="generator" content="WebCritic/<%= $App::WebCritic::VERSION %>">
    <script src="/js/jquery.min.js"></script>
    <script src="/js/bootstrap.min.js"></script>
    <title><%= title %> - WebCritic/<%= $App::WebCritic::VERSION %></title>
    <style>
      h1.top { float: left; }
      nav.top { float: right; }
      .cb { clear: both; }
      .left { float: left; }
      .right { float: right; }
      .center { margin: 0 auto; }
    </style>
  </head>
  <body>
    <div class="navbar navbar-inverse navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container">
          <a class="brand" href="/"><img src="/img/logo.png"> WebCritic</a>
          <div class="nav-collapse">
            <ul class="nav">
              <li>
                <a href="/config">Config</a>
              </li>
              <li>
                <a href="/log">Logs</a>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
    <article>
      <%= content %>
    </article>
    <div class="powered">Powered by <a href="http://github.com/h15/app-webcritic">WebCritic</a> /
      <a href="http://mojolicio.us">Mojolicious</a> /
      <a href="http://perl.org">Perl</a>
    </div>
  </body>
</html>


@@ index.html.ep
% layout 'default', title => "WebCritic";