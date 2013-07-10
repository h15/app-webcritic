#! /usr/bin/env perl
use Pony::Object ':noobject';

my $root_dir = './t/01/site';
my @digits;

push @digits, int(rand 100) for 0..int(rand 10) + 1;

# init
for my $name (@digits) {
  open(my $fh, ">>$root_dir/$name.html") or die;
  print $fh qq {
    <html>
      <head>
        <title>title $name</title>
      </head>
      <body>
        $name
      </body>
    </html>
  };
  close $fh;
}

my @files = generate_subdir($root_dir, 10);

# Create index
open(my $fh, ">>$root_dir/index.html") or die;
  print $fh qq {
    <html>
      <head>
        <title>Index</title>
      </head>
      <body>
        <ul>
  };
  print $fh qq{<li><a href="$_">$_</li>} for @files;
  print $fh qq{
        </ul>
      </body>
    </html>
  };
close $fh;


# Generate dirs and files
sub generate_subdir {
  my ($dir, $depth) = @_;
  my @files;
  
  # Last level
  unless ($depth--) {
    for (<$dir/*>) {
      push @files, (/^$root_dir(.*)/) if -f
    }
    return @files;
  }
  
  my ($site) = ($dir =~ /^$root_dir(.*)/);
  my @nums;
  
  opendir(my $dh, $dir) or die;
  while (readdir $dh) {
    push @nums, (/(\d+)\.html$/);
  }
  closedir $dh;
  
  for my $n (@nums) {
    my $start = int(rand() * $#nums/2);
    my $end = $start + int(rand() * $#nums/2);
    my @slice = @nums[$start .. $end];
    
    mkdir "$dir/$n";
    
    for my $s (@slice) {
      my $file = $n + $s;
      open(my $fh, ">>$dir/$n/$file.html");
      print $fh qq{
        <html>
          <head>
            <title>title $file</title>
          </head>
          <body>
            <a href="$site/$n.html">$n</a> + <a href="$site/$s.html">$s</a>
          </body>
        </html>
      };
      close $fh;
      
      push @files, generate_subdir("$dir/$n", $depth);
    }
  }
  return @files;
}