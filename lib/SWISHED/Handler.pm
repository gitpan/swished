package SWISHED::Handler;
# this is the script that implements the swished daemon with mod_perl 2.0 

use lib '/usr/local/swished/lib';
use SWISHED::Core;
use strict;
use warnings;

# these require mod_perl w/ apache 2.0!
use Apache::RequestRec ();
use Apache::RequestIO (); 
use Apache::Const -compile => qw(OK);

# by default will use the index specified in $ENV{'SWISHED_INDEX_DEFAULT'}
# if the

sub handler {
	my $r = shift;
	$r->content_type('text/plain'); 
	SWISHED::Core::do_search();	# this uses CGI.pm to handle mod_perl-ness 
	return Apache::OK;
}

1;

__END__

=head1 NAME

SWISHED::Handler - perl module to provide a persistent swish-e daemon

=head1 SYNOPSIS

Put lines like the following in your httpd.conf file:

	PerlRequire /usr/local/swished/lib/startup.pl
	PerlPassEnv SWISHED_INDEX_DEFAULT 
	<Location /swished>
		PerlResponseHandler SWISHED::Handler
		PerlSetEnv SWISHED_INDEX_DEFAULT /var/lib/sman/sman.index
		SetHandler perl-script
	</Location> 

=head1 DESCRIPTION 

Swished is a mod_perl module providing a persistent swish-e daemon

=head1 AUTHOR

Josh Rabinowitz

=head1 SEE ALSO

L<SWISHED::Core>, L<SWISH::API>, L<SWISH::API::Remote>

=cut

