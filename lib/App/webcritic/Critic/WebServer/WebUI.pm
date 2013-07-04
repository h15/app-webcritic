# Class: App::webcritic::Critic::WebServer::WebUI
#   Web user interface.
# Implements:
#   App::webcritic::Critic::Log::AbstractLogger
package App::webcritic::Critic::WebServer::WebUI;
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
@@ css/style.css
nav, header, article, footer { display: block; }
html {
  padding:0px;
  margin:0px;
  height: 80%;
  /* Gradient */
  filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#dc7029', endColorstr='#ffffff'); /* for IE */
  background: -webkit-gradient(linear, left top, left bottom, from(#dc7029), to(#ffffff)); /* for webkit browsers */
  background: -moz-linear-gradient(top, #dc7029, #ffffff); /* for firefox 3.6+ */
  background-repeat: no-repeat;
  background-attachment: fixed;
}
body {
  padding:0px;
  margin:10px 0px 0px 0px;
  height:100%;
  width:100%;
  font-family:Sans;
  color:#444;
  font-size: 14px;
}
a { color: #26c; text-decoration: none; }
h1,h2,h3,h4,h5,h6 { padding-top:0px; margin-top:0px; }
.cb { clear: both; }
body>nav {
  width:600px;
  margin:0px auto;
  padding:0px 10px 0px 10px;
}
.done, .error, .info, .rounded {
  padding: 10px;
  padding-right: 15px;
  background:#F2F1F0;
  border: 1px solid #ddd;
  -moz-border-radius: 5px;
  -webkit-border-radius: 5px;
  border-radius: 5px;
  -khtml-border-radius: 5px;
}
.done, .error, .info { text-align:center; margin: 0px; }
.info { background: #ffd; border: 1px solid #fff7dd; }
.error { background: #fee; border: 1px solid #fcc; margin: 0px auto; }
.done { background: #efe; border: 1px solid #cfc; }
.hidden { display:none; }
.aligncenter { margin:auto; }
.alignright { float:right; }
.alignleft { float:left; }
.page {
  margin:0px auto;
  padding:10px 10px 0px 10px;
  width:600px;
  height:100%;
  color:#222;
  font-family:Sans, Arial;
  background:#fff;
  border: 1px solid #fff;
  -moz-border-radius:10px 10px 10px 10px;
  -webkit-border-radius:10px 10px 10px 10px;
  border-radius:10px 10px 10px 10px;
  -khtml-border-radius:10px 10px 10px 10px;
}
body>header>h1 { color: #fff; }
body>header { margin:20px auto; width:600px; }
body>footer { margin:0px auto 20px auto; width:600px; height:20px; }
.form { width:300px; }
.form td { padding:5px; }
.icon { height: 32px; }
.wide { display:block; width:100%; }
body>nav>div>a { background: #fff; color: #a44; padding: 4px; margin-right: 10px; display: block; float: left;   -moz-border-radius: 5px;  -webkit-border-radius: 5px;  border-radius: 5px;  -khtml-border-radius: 5px;}
body>nav>div>a:hover { color: #a00; text-decoration: underline; }
.powered { text-align:center;font-size:12px;margin:20px 0px; }
.keys { text-align: center; list-style: none; padding: 0px; }
.top-menu { margin-top: 5px; }
.top-menu a { color: #fff; margin: 10px; font-size: 18px; }


@@ layouts/default.html.ep
<!doctype html>
<html>
  <head>
    <title><%= title %></title>
    <link href="/css/style.css" rel="stylesheet">
    <meta name="generator" content="Gitty <%= $::VERSION %>">
    <meta charset="utf-8">
  </head>
  <body>
    <nav>
      % if (session('id') && session('id') == 1) {
        <div>
          <a href="/admin/users">Users</a>
          <a href="/admin/config/startup">Startup-Config</a>
          <a href="/admin/config/running">Running-Config</a>
          <a href="/admin/config/gitty">Gitty-Config</a>
        </div>
      % }
    </nav>
    <div class=cb></div>
    <header>
      <div class="alignright top-menu">
        <a href="/config">Configs</a>
        <a href="/log">Logs</a>
      </div>
      <h1><%= title %></h1>
    </header>
    <div class=cb></div>
    <article class="page">
      <div style="height: 100%;">
        <%= content %>
      </div>
    </article>
    <div class="powered">Powered by <a href="http://github.com/h15/app-webcritic">WebCritic</a> /
      <a href="http://mojolicio.us">Mojolicious</a> /
      <a href="http://perl.org">Perl</a>
    </div>
  </body>
</html>

@@ index.html.ep
% layout 'default', title => "WebCritic";