# this is the script that implements the swished daemon
package SWISHED;
use strict;
use warnings;

use vars qw($VERSION); 
# this module is used only for the VERSION line below and the perldocs
$VERSION = '0.08';

1;

__END__

=head1 NAME

swished - a set of perl modules to provide a persistent swish-e daemon. 
A reference implementation intended to be used with SWISH::API::Remote.

=head1 SYNOPSIS

See the documentation for 'swished' or 'SWISHED::Handler'

=head1 DESCRIPTION

From the README:

This will install the module and associated files get installed into 
/usr/local/swished. 

	/usr/local/swished/cgi-bin/swished   is the CGI and Apache::Registry version
	/usr/local/lib/SWISHED/Handler.pm    is the mod_perl 2.0 Apache Handler
	/usr/local/lib/startup.pl            is the mod_perl 2.0 startup script

To run as a mod_perl 2.0 module, add lines like the 
following to your mod_perl httpd.conf file:

	PerlRequire /usr/local/swished/lib/startup.pl
	PerlPassEnv SWISHED_INDEX_DEFAULT 
	PerlPassEnv SWISHED_INDEX_INDEX2 
	<Location /swished>
		PerlResponseHandler SWISHED::Handler
		PerlSetEnv SWISHED_INDEX_DEFAULT /var/lib/sman/sman.index
		# set this to your default index
		PerlSetEnv SWISHED_INDEX_INDEX2  /your/collection.index
		SetHandler perl-script
	</Location>

To run as a Apache::Registry modules, place lines like 
the following in your httpd.conf file

	Alias /swished/  /usr/local/swished/cgi-bin/
	PassEnv SWISHED_INDEX_DEFAULT
	<Location /swished> 
		SetHandler  perl-script
		PerlHandler Apache::Registry
		Options +ExecCGI
		SetEnv SWISHED_INDEX_DEFAULT /var/lib/sman/sman.index
		# set this to your default index
	</Location>

You could test the above mod_perl configuration via a command like:

	lynx 'http://yourserverasdf.com/swished?w=my+search' 

or you could test the CGI or Apache::Registry installation with command like:
	
	lynx 'http://yourserveradsf.com/swished/swished?w=my_search'

the format for the text you'll see is explained in the file PROTOCOL
and is expected to be read by SWISH::API::Remote 
(see L<http://joshr.com/src/SWISH-API-Remote/>)

=head1 SEE ALSO

L<SWISH::API>, L<SWISH::API::Remote>, L<SWISHED::Handler>, L<SWISHED::swished>

=head1 AUTHOR

joshr, C<< <joshr> >>

=head1 Copyright & License

Copyright 2004 joshr, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
