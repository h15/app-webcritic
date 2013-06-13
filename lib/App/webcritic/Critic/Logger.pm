package App::webcritic::Critic::Logger;
use Pony::Object -abstract;
use Pony::Object::Throwable;

my $level = 'debug';
my $level_list = {
  debug => 00,
  info  => 20,
  warn  => 40,
  error => 60,
  fatal => 80,
};

# Generate log_* methods
for my $lvl (keys %$level_list) {
  has "log_$lvl" => sub {
    my $self = shift;
    my $content = shift;
    return if $level_list->{$lvl} < $level_list->{$level};
    $self->write_log($lvl, $content);
  };
}
  
  protected level => 'info';
  
  sub set_level : Public
    {
      my $this = shift;
      my $new_level = shift;
      
      throw Pony::Object::Throwable("Unknown level \"$new_level\"")
        unless exists $level_list->{$new_level};
      
      $level = $new_level;
    }
  
  sub write_log : Public
    {
      my $this = shift;
      my ($level, $content) = @_;
      my $res = *STDOUT;
      #$content = $content->dump() if $content->isa('Pony::Object');
      printf $res "[%5s] %s\n", $level, $content;
    }
  
1;