# this is the script that implements the swished daemon
package SWISHED::Core;
use strict;
use warnings;

use SWISH::API;
use URI::Escape;	# for uri_escape() and uri_unescape()
use CGI;			# for param()

use vars qw( %swish_apis );	# persistent hash of indexnames -> SWISHE::APIs
sub close_indices { %swish_apis = (); }

sub do_search {
	# our protocol is based on the swish-e command line exe.
	# we expect a query string with the following
	# a=action (S for search or M for metadata)
	# f=indexname (looks for env var SWISHED_INDEX_INDEXNAME)
	#   indexname must match /^[a-z_]+\w*$/ and will be uppercased
	#   default is to use SWISHED_INDEX_DEFAULT
	# w=search
	# p=prop,prop2,prop3 
	# m=max 
	# b=begin
	# s=sort string 

		# default swish properties include:
		#	swishdocpath swishrank swishdocsize swishtitle swishdbfile 
		#	swishlastmodified swishreccount swishfilenum 

	# these read from $r->args under modperl
	my $w = CGI::param("w") || "";	# word to search for
	my $b = CGI::param("b") || 0;	# begin results at rec num
	my $m = CGI::param("m") || 10;	# max results
	my $p = CGI::param("p") || "swishdocpath,swishrank,swishtitle";
	my @props = split(/,/, $p);
	my $d = CGI::param("d") || "";	# debug level
	my $s = CGI::param("s") || "";  # sort spec
	my $f = CGI::param("f") || "DEFAULT"; 
	
	#$ENV{test} = "TEST"; while (my ($k, $v) = each %ENV) { print ("ENV{$k} = $ENV{$k}\n"); }

	print("e: swished.modperl: not a valid indexname: $f\n") && return 
		unless $f =~ /^[a-zA-Z]+\w*$/i;
	print("e: swished.modperl: no index found by name: SWISHED_INDEX_$f\n") && return 
		unless exists($ENV{ "SWISHED_INDEX_$f" });

	my $index = $ENV{ "SWISHED_INDEX_$f" };

	unless( exists $swish_apis{$f} ) {
		$swish_apis{$f} = SWISH::API->new ( $index );
		print("d: pid $$ opened index $index for search '$w'\n");
	}
	my $swish = $swish_apis{$f}; 
	my $search = $swish->New_Search_Object();
	#print "Searching for $w in $index\n";

	print("e: " . $swish->ErrorString() . "\n") if $swish->Error(); 
	print("k: " . join("&", map { "$_=$props[$_]" } (0 .. $#props)) . "\n" );

	if ($w) {
		my $results;
		eval { 
			$search->SetSort( $s ) if $s;
			$results = $search->Execute( $w );
			$results->SeekResult( $b ) if $b;
		};
		if ($@) { print("e: $@\n"); };
		my $cnt = 0;
		eval {
			print("m: hits=" . $results->Hits() . "&swished_version=$SWISHED::VERSION\n");
			no warnings;	# skip complaints about undefs from $result-Property()
			while ( ($cnt++ < $m) && (my $result = $results->NextResult() ) ) { 
				print( "r: " .  join("&", 
					map { "$_=" . uri_escape($result->ResultPropertyStr( $props[$_] ) )  } 
						(0 .. $#props) 
				) . "\n" ); 
			}
		};
		if ($@) { print("e: $@\n"); };
	} 
}

1;


=head1 NAME

SWISHED::Core - perl module to provide a persistent swish-e daemon

=head1 SYNOPSIS

Put lines like the following in your httpd.conf file to use SWISHED as a 
mod_perl 2.0 handler. See the docs for examples on how to use swished
as a CGI or Apache::Registry handler:

	PerlRequire /usr/local/swished/lib/startup.pl
	PerlPassEnv SWISHED_INDEX_DEFAULT 
	<Location /swished>
		PerlResponseHandler SWISHED::Handler
		PerlSetEnv SWISHED_INDEX_DEFAULT /var/lib/sman/sman.index
		# specify your default index here, above is from Sman
		SetHandler perl-script
	</Location> 

=head1 DESCRIPTION 

Swished is the core module providing a persistent swish-e daemon. See SWISHED::swished
and SWISHED::Handler for examples.

=head1 AUTHOR

Josh Rabinowitz

=head1 SEE ALSO

L<SWISH::API>, L<SWISH::API::Remote>, L<SWISHED::Handler>, L<SWISHED::swished>, L<swish-e>

=cut

