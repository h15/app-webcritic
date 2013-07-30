# Class: App::webcritic::Critic::WebServer::WebUI
#   Web user interface.
# Implements:
#   App::webcritic::Critic::Log::AbstractLogger
package App::webcritic::Critic::WebServer::WebUI;
use File::Spec::Functions 'catdir';
use JSON::XS;
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
            return decode_json($data);
          }
          return {};
        } catch {
          return {};
        };
        my $idents = $this->get_config_list('./conf/local');
        return $self->stash(list => $list, conf => $conf, idents => $idents)->render('config');
      };
      
      post '/config' => sub {
        my $self = shift;
        my $file = $self->param('file');
        $self->session('config_name' => $file);
        $self->redirect_to('/config');
      };
      
      get '/config/new' => sub {
        my $self = shift;
        $self->render('config/new_form');
      };
      
      post '/config/new' => sub {
        my $self = shift;
        my $name = $self->param('name') or die 'Name must be defined';
        my $ident= $self->param('identifier') or die 'Identifier must be defined';
        my $url  = $self->param('url') or die 'Url must be defined';
        
        die qq{File "./conf/local/$ident.json" already exists} if -f "./conf/local/$ident.json";
        open(my $fh, ">>", "./conf/local/$ident.json") or die "Can't create file ./conf/local/$ident.json";
        
        say $fh encode_json({
          "site_list" => [{
            "url" => $url,
            "name" => $name,
          }]
        });
        
        close $fh;
        $self->redirect_to('/config');
      };
      
      get '/config/show/:ident' => sub {
        my $self = shift;
        my $ident = $self->param('ident');
        open(my $fh, "./conf/local/$ident.json") or return $self->render_not_found;
        my $data = <$fh>;
        close $fh;
        $data = decode_json($data);
        
        # Fill empty options' fields
        for my $i (keys @{$data->{site_list}}) {
          $data->{site_list}->[$i]->{options} = {} unless exists $data->{site_list}->[$i]->{options};
          $data->{site_list}->[$i]->{options}->{log} = {
            "level"   => "debug",
            "adaptor" => "App::webcritic::Critic::Log::Adaptor::SimpleTerm",
            "options" => { "path" => "./log/local" }
          } unless exists $data->{site_list}->[$i]->{options}->{log};
          $data->{site_list}->[$i]->{options}->{sleep} = 1
            unless exists $data->{site_list}->[$i]->{options}->{sleep};
          $data->{site_list}->[$i]->{options}->{exclude} = []
            unless exists $data->{site_list}->[$i]->{options}->{exclude};
          $data->{site_list}->[$i]->{options}->{policies} = {}
            unless exists $data->{site_list}->[$i]->{options}->{policies};
        }
        
        $self->stash(%$data)->render('config/show');
      };
      
      post '/config/show/:ident' => sub {
        my $self = shift;
        my $ident = $self->param('ident');
      } => 'config_edit';
      
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
        next if $file =~ /\/\..*?$/;
        next if $file !~ /\.json$/;
        my ($ident) = ($file =~ m/([^\/]*)\.json$/);
        push @list, $ident;
      }
      
      return \@list;
    }
  
1;

__DATA__

@@ layouts/default.html.ep
% use App::webcritic;
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <link href="/css/bootstrap.min.css" media="screen" rel="stylesheet" />
    <meta name="generator" content="WebCritic/<%= $App::webcritic::VERSION %>">
    <script src="/js/jquery.min.js"></script>
    <script src="/js/bootstrap.min.js"></script>
    <script src="/js/main.js"></script>
    <title><%= title %> - WebCritic/<%= $App::webcritic::VERSION %></title>
    <style>
      body { width: 100%; }
      h1.top { float: left; }
      nav.top { float: right; }
      .cb { clear: both; }
      .left { float: left; }
      .right { float: right; }
      .center { margin: 0px auto; }
      article.top { min-height: 600px; width: 800px; margin: 100px auto; }
      .powered { text-align: center; }
      body > .navbar .brand {
        padding-right: 0;
        padding-left: 0;
        margin-left: 20px;
        float: right;
        font-weight: bold;
        color: black;
        text-shadow: 0 1px 0 rgba(255, 255, 255, .1), 0 0 30px rgba(255, 255, 255, .125);
        -webkit-transition: all .2s linear;
        -moz-transition: all .2s linear;
        transition: all .2s linear;
      }
    </style>
  </head>
  <body>
    <div class="navbar navbar-inverse navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container">
          <a class="brand" href="/">WebCritic</a>
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
    <article class="top">
      <div class="container span12 center">
        <%= content %>
      </div>
    </article>
    <div class="powered">Powered by
      <a href="http://github.com/h15/app-webcritic">WebCritic</a> /
      <a href="http://mojolicio.us">Mojolicious</a> /
      <a href="http://perl.org">Perl</a>
    </div>
  </body>
</html>


@@ index.html.ep
% layout 'default', title => "WebCritic";


@@ config/show.html.ep
% layout 'default', title => "Edit config $ident";
% for my $i (keys @$site_list) {
%   my $name = $site_list->[$i]->{name};
%   my $url  = $site_list->[$i]->{url};
%   my $opt  = $site_list->[$i]->{options};
<h2>Website "<%= $name %>"</h2>
<div class="class6 offset2">
  <form class="form-horizontal" method="post" action=<%= url_for(config_edit => ident => $ident) %>>
    <input type="hidden" name="offset" value="<%= $i %>">
    <div class="control-group">
      <label class="control-label" for="configName-<%= $i %>">Name</label>
      <div class="controls">
        <input type="text" id="configName-<%= $i %>" name="name[]" placeholder="Name" value="<%= $name %>">
      </div>
    </div>
    <div class="control-group">
      <label class="control-label" for="configIdentifier-<%= $i %>">Identifier</label>
      <div class="controls">
        <input type="text" id="configIdentifier-<%= $i %>" name="identifier[]"
          disabled="disabled" placeholder="Identifier" value="<%= $ident %>">
      </div>
    </div>
    <div class="control-group">
      <label class="control-label" for="configUrl-<%= $i %>">URL</label>
      <div class="controls">
        <input type="text" id="configUrl-<%= $i %>" name="url[]" placeholder="URL" value="<%= $url %>">
      </div>
    </div>
    <div class="control-group">
      <label class="control-label" for="configLogLevel-<%= $i %>">Log level</label>
      <div class="controls">
        <select id="configLogLevel-<%= $i %>" name="log[][level]">
          <option <%= ($opt->{log}->{level} eq 'debug' ? 'selected=selected' : '') %>>debug</option>
          <option <%= ($opt->{log}->{level} eq 'info'  ? 'selected=selected' : '') %>>info</option>
          <option <%= ($opt->{log}->{level} eq 'warn'  ? 'selected=selected' : '') %>>warn</option>
          <option <%= ($opt->{log}->{level} eq 'error' ? 'selected=selected' : '') %>>error</option>
          <option <%= ($opt->{log}->{level} eq 'fatal' ? 'selected=selected' : '') %>>fatal</option>
          <option <%= ($opt->{log}->{level} eq 'off'   ? 'selected=selected' : '') %>>off</option>
        </select>
      </div>
    </div>
    <div class="control-group">
      <label class="control-label" for="configLogAdaptor-<%= $i %>">Log adaptor</label>
      <div class="controls">
        <input type="text" id="configLogAdaptor-<%= $i %>" name="log[][adaptor]"
          placeholder="Adaptor" value="<%= $opt->{log}->{adaptor} %>">
      </div>
    </div>
    <div class="control-group">
      <label class="control-label" for="configLogOptionsPath-<%= $i %>">Log adaptor</label>
      <div class="controls">
        <input type="text" id="configLogOptionsPath-<%= $i %>" name="log[][adaptor][options][path]"
          placeholder="Path" value="<%= $opt->{log}->{options}->{path} %>">
      </div>
    </div>
    <div class="control-group">
      <label class="control-label" for="configSleep-<%= $i %>">Sleep (in sec)</label>
      <div class="controls">
        <input type="text" id="configSleep-<%= $i %>" name="sleep[]" placeholder="Sleep" value="<%= $opt->{sleep} %>">
      </div>
    </div>
    <div class="control-group">
      <label class="control-label" for="configExclude-<%= $i %>">Exclude (path list)</label>
      <div class="controls">
        <input type="text" id="configExclude-<%= $i %>" name="exclude[]" placeholder="Exclude path" value="<%= join(', ', @{$opt->{exclude}}) %>">
      </div>
    </div>
    <div class="control-group">
      <label class="control-label">
        <button type="reset" class="btn btn-link">Cancel</button>
      </label>
      <div class="controls">
        <button type="submit" class="btn">Edit</button>
      </div>
    </div>
  </form>
</div>
<hr>
% }


@@ config/new_form.html.ep
% layout 'default', title => "Create new config";
<div class="class6 offset2">
  <form class="form-horizontal" method="post" action="/config/new">
    <div class="control-group">
      <label class="control-label" for="configName">Name</label>
      <div class="controls">
        <input type="text" id="configName" name="name" placeholder="Name">
      </div>
    </div>
    <div class="control-group">
      <label class="control-label" for="configIdentifier">Identifier</label>
      <div class="controls">
        <input type="text" id="configIdentifier" name="identifier" placeholder="Identifier">
      </div>
    </div>
    <div class="control-group">
      <label class="control-label" for="configUrl">URL</label>
      <div class="controls">
        <input type="text" id="configUrl" name="url" placeholder="URL">
      </div>
    </div>
    <div class="control-group">
      <label class="control-label"></label>
      <div class="controls">
        <button type="submit" class="btn">Create</button>
      </div>
    </div>
  </form>
  <script>
    $(document).ready(function() {
      $('#configName').keyup(function() {
        $('#configIdentifier').val( trCyrillicToLatin($(this).val()) );
      });
    });
  </script>
</div>


@@ config.html.ep
% layout 'default', title => "Config";
% unless (%$conf) {
<form method="post" action="/config/show" class="span5">
  <div class="input-prepend input-append">
    <span class="add-on">Select config</span>
    <select name="ident">
    % for my $fl (@$idents) {
      <option value="<%= $fl %>"><%= $fl %></option>
    % }
    </select>
    <button type="button" class="btn"
      onClick="window.location = $(this).parent().parent().attr('action')
        + '/' + $(this).parent().parent().find('select').val()">Select</button>
  </div>
</form>
... or create <a href="/config/new" class="btn btn-success" type="button">
  <i class="icon-plus icon-white"></i> new</a> config.
% } else {
Config:
<textarea name=config><%= dumper $conf %></textarea>
% }