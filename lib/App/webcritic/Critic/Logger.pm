package App::webcritic::Critic::Logger;
use Pony::Object;
use Pony::Object::Throwable;

  protected static level => 'debug';
  protected static level_list => {
    debug => 00,
    info  => 20,
    warn  => 40,
    error => 60,
    fatal => 80,
  };
  
  sub init : Public
    {
      my $this = shift;
      
      # Generate log_* methods
      for my $lvl (keys %{$this->level_list}) {
        unless ($this->can("log_$lvl")) {
          has "log_$lvl" => sub {
            my $self = shift;
            my $content = shift;
            return if $this->level_list->{$lvl} < $this->level_list->{$this->level};
            $self->write_log($lvl, $content);
          };
        }
      }
    }
  
  sub set_level : Public
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
      my ($level, $content) = @_;
      my $res = *STDOUT;
      #$content = $content->dump() if $content->isa('Pony::Object');
      printf $res "[%5s] %s\n", $level, $content;
    }
  
1;