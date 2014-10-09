=head1 NAME

App::LedgerSMB::Admin::Auth - Authenticate Web Users for LSMB Admin Tasks

=cut

package App::LedgerSMB::Admin::Auth;
use Dancer ':syntax';
use Dancer::Response;
use HTTP::Headers;
use MIME::Base64;
use strict;
use warnings;

=head1 SYNOPSIS

 my $db = authenticate(host => 'localhost', port => 5432, dbname => 'lsmb');

=head1 FUNCTIONS

=head2 authenticate

This function grabs the parameters of host and port from the arg hash and the
username and password from the authentication header, and returns a db object
with a connection.  If the connection fails, it returns a 401 error.

Currently only basic auth is supported but there are plans to add krb5 auth
in the near future.

We currently return a 401 any time the db connection fails for any reason.
This is to prevent using the tool to scan for db servers for further attacks.

=cut

sub authenticate {
    my %args = @_;
    my $header = request->header('Authorization');
    my ($user, $password) = split(/:/, (MIME::Base64::decode($1) || ":"));
    return _fail_auth() unless $user;
    my $db = App::LedgerSMB::Admin::Database->new(%args,
                                                  username => $user,
                                                  password => $password,
    );
    return $db if $db->connect;
    return _fail_auth();
}

sub _fail_auth {
    my $authmsg = 'Authorization Required';    
    return halt(Dancer::Response->new(
        status => 401,
        content => $authmsg,
        headers => [
            'Content-Type' => 'text/plain',
            'Content-Length' => length($authmsg),
            'WWW-Authenticate' => 'Basic realm="LedgerSMB Admin"',
        ]
    ));
}

=head1 LICENSE AND COPYRIGHT

Copyright 2014 Chris Travers.

This program is distributed under the (Revised) BSD License:
L<http://www.opensource.org/licenses/BSD-3-Clause>

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

* Neither the name of Chris Travers's Organization
nor the names of its contributors may be used to endorse or promote
products derived from this software without specific prior written
permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1;
