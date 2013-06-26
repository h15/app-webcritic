package My::Util;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(dir_to_hash);

# Function: dir_to_hash
#   read dir and shows as hash path=>file_content
#
# Parameters:
#   $dir - Str - path to dir
#
# Returns:
#   %hash - Hash
sub dir_to_hash {
  my ($dir) = @_;
  my %hash;
  local $/;
  
  for my $f (<$dir/*>) {
    if (-d $f) {
      %hash = (%hash, dir_to_hash("$f"));
    }
    elsif (-f $f) {
      if (-B $f) {
        open(my $fh, '<', $f) or die "Can't read $f";
        binmode $fh;
        my $data = <$fh>;
        close $fh;
        %hash = (%hash, "$f" => $data);
      } else {
        open(my $fh, '<utf8', $f) or die "Can't read $f";
        my $data = <$fh>;
        close $fh;
        %hash = (%hash, "$f" => $data);
      }
    }
  }
  return %hash;
}

1;