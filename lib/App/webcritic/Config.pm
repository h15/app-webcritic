package App::webcritic::Config;
use Pony::Object;

  protected 'config' => {};
  private 'possible_configs' => {
    'config' => 'c',
    'url' => 'u',
  };

  sub init : Public
    {
      my $this = shift;
      my $param = join ' ', @_;
      
      LOOP: {
        $this->add_param($1, $2), redo LOOP if $param =~ /\G\s*--([a-z\-]+)(?:=|\s+)(.+)(?:\s|$)/gcx;
        $this->add_param($1)    , redo LOOP if $param =~ /\G\s*--([a-z\-]+)             (?:\s|$)/gcx;
        $this->add_short($1, $2), redo LOOP if $param =~ /\G\s*- ([a-z])   (?:=|\s+)(.+)(?:\s|$)/gcx;
        $this->add_short($1)    , redo LOOP if $param =~ /\G\s*- ([a-z])                (?:\s|$)/gcx;
      }
      # TODO: error if param unknown.
    }
  
  sub add_param : Public
    {
      my $this = shift;
      my ($key, $val) = (@_, 1);
      die "Invalid key $key" unless exists $this->possible_configs->{$key};
      $this->config->{$key} = $val;
    }
  
  sub add_short : Public
    {
      my $this = shift;
      my ($key, $val) = (@_, 1);
      my %short = reverse %{$this->possible_configs};
      die "Invalid key $key" unless exists $short{$key};
      $key = $short{$key};
      $this->config->{$key} = $val;
    }
  
  sub get : Public
    {
      my $this = shift;
      my ($key) = @_;
      return undef unless exists $this->config->{$key};
      return $this->config->{$key};
    }

1;