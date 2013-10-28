package App::webcritic::Web;
use mop;
use Socket;

use App::webcritic::Log;

class Site with App::webcritic::Log::Logger {
  has $!name;
  has $!url;
  has $!domain;
  has $!host;
  has $!first_page;
  has $!page_list = [];
  has $!page_by_url = {};
  has $!exist_page_list = {};
  has $!options;
  
  method new($url, $name, $opts) {
    ($!url, $!name, $!options) = ($url, $name, $opts);
    if ($!options->{log}) {
      $self->set_log_level($!options->{log}->{level}) if $!options->{log}->{level};
      App::webcritic::Log::Factory->new->set_default_log($!options->{log}->{adaptor}) if $!options->{log}->{adaptor};
      App::webcritic::Log::Factory->new->set_log_adaptor_options($!options->{log}->{options}) if $!options->{log}->{options};
      $self->set_log_adaptor(App::webcritic::Log::Factory->get_log())
    }
    $!name ||= 'Site '.$!url;
    ($!domain) = ($!url =~ m/\w+:\/\/([\w\d\-\.:]+)/); # domain with port
    $!host = eval { inet_aton $!domain } || '0.0.0.0';
    $!first_page = App::webcritic::Web::Page->new($self, App::webcritic::Web::Link->new($!url), 1);
    $self->add_page($!first_page);
  }
}

1;