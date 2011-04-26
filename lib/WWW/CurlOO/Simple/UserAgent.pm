package WWW::CurlOO::Simple::UserAgent;

use strict;
use warnings;
use WWW::CurlOO::Share qw(CURLSHOPT_SHARE /^CURL_LOCK_DATA_/);
use Scalar::Util qw(looks_like_number);
use base qw(WWW::CurlOO::Share);

our $VERSION = 0.01;

my %common_options = (
	useragent => __PACKAGE__ . " v$VERSION",
);

sub setopts
{
	my $share = shift;
	my %opts = @_;

	$share = \%common_options
		unless ref $share;

	@$share{ keys %opts } = values %opts;
}
*setopt = \&setopts;

sub new
{
	my $class = shift;

	my $share = $class->SUPER::new();

	$share->SUPER::setopt( CURLSHOPT_SHARE, CURL_LOCK_DATA_COOKIE );
	$share->SUPER::setopt( CURLSHOPT_SHARE, CURL_LOCK_DATA_DNS );
	$share->setopts( %common_options, @_ );

	return $share;
}

sub curl
{
	my $share = shift;
	require WWW::CurlOO::Simple;
	return WWW::CurlOO::Simple->new( %$share, @_, share => $share );
}

1;

=head1 NAME

WWW::CurlOO::Simple::UserAgent - share some data between multiple WWW::CurlOO::Simple objects

=head1 SYNOPSIS

 use WWW::CurlOO::Simple::UserAgent;

 # options for all out user agents
 WWW::CurlOO::Simple::UserAgent->setopt(
     useragent => "My::Downloader",
 );

 # this one uses socks for connection
 my $ua = WWW::CurlOO::Simple::UserAgent->new(
     proxy => "socks5://localhost:9980/",
 );

 # those two requests share cookies and options set before
 $ua->curl()->get( $uri, \&finished );
 $ua->curl()->get( $uri2, \&finished );

 sub finished
 {
     my ( $curl, $result ) = @_;
     print "document body: $curl->{body}\n";
 }

=head1 DESCRIPTION

C<WWW::CurlOO::Simple::UserAgent> provides a method to preset some options
for multiple L<WWW::CurlOO::Simple> objects and allow them to share cookies.

=head1 SPECIAL METHODS

If setopt() or setopts() is called with package name and not an object, it will
alter default UserAgent options. All newely-created user agents will share
those options.

=head1 CONSTRUCTOR

=over

=item new( [GLOBAL_OPTIONS] )

Creates new WWW::CurlOO::Simple::UserAgent object.

 my $ua = WWW::CurlOO::Simple::UserAgent->new( timeout => 60 );

=back

=head1 METHODS

=over

=item setopt( NAME, VALUE )

Set option for all new curl instances. It will not alter any curl instances
created already.

=item setopts( GLOBAL_OPTIONS )

Set multiple curl options.

=item curl( [PERMANENT_OPTIONS] )

Get new L<WWW::CurlOO::Simple> instance attached to this user agent. Options
will be passed to new() constructor and will not affect any other instances.

=back

=head1 OPTIONS

Options can be either CURLOPT_* values (import them from WWW::CurlOO::Easy),
or literal names, preferably in lower case, without the CURLOPT_ preffix.
For description of available options see L<curl_easy_setopt(3)>.

=head1 SEE ALSO

L<WWW::CurlOO::Simple>
L<WWW::CurlOO::Simple::Async>
L<WWW::CurlOO::Easy>
L<WWW::CurlOO::Share>

=head1 COPYRIGHT

Copyright (c) 2011 Przemyslaw Iskra <sparky at pld-linux.org>.

This program is free software; you can redistribute it and/or
modify it under the same terms as perl itself.

=cut

# vim: ts=4:sw=4
