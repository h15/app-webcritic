package App::webcritic::Critic::Logger;
use Pony::Object;
use Pony::Object::Throwable;

  protected level => 'debug';
  protected static level_list => {
    debug => 00,
    info  => 20,
    warn  => 40,
    error => 60,
    fatal => 80,
  };
  
  sub set_log_level : Public
    {
      my $this = shift;
      my $new_level = shift;
      
      throw Pony::Object::Throwable("Unknown level \"$new_level\"")
        unless exists $this->level_list->{$new_level};
      
      $this->level = $new_level;
    }
  
  sub write_log : Public
    {
      my $this = shift;
      my ($level, @content) = @_;
      my $content = shift @content;
      $content = sprintf $content, @content if @content;
      
      my $res = *STDOUT;
      printf $res "[%5s] %s\n", $level, $content;
    }
  
  sub log_debug : Public
    {
      my $this = shift;
      my @content = @_;
      return if $this->level_list->{debug} < $this->level_list->{$this->level};
      $this->write_log('debug', @content);
    }
  
  sub log_info : Public
    {
      my $this = shift;
      my @content = @_;
      return if $this->level_list->{info} < $this->level_list->{$this->level};
      $this->write_log('info', @content);
    }
  
  sub log_warn : Public
    {
      my $this = shift;
      my @content = @_;
      return if $this->level_list->{warn} < $this->level_list->{$this->level};
      $this->write_log('warn', @content);
    }
  
  sub log_error : Public
    {
      my $this = shift;
      my @content = @_;
      return if $this->level_list->{error} < $this->level_list->{$this->level};
      $this->write_log('error', @content);
    }
  
  sub log_fatal : Public
    {
      my $this = shift;
      my @content = @_;
      return if $this->level_list->{fatal} < $this->level_list->{$this->level};
      $this->write_log('fatal', @content);
    }
  
1;