package App::webcritic;
use Web::Query;

our $VERSION = '0.01';
$Web::Query::UserAgent = LWP::UserAgent->new(agent => "webcritic/$App::webcritic::VERSION");

__END__

=pod

=head1 NAME

App::webcritic - A critic for web-sites.

=head1 OVERVIEW


=cut
