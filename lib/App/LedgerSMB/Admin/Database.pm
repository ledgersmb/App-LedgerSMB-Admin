package App::LedgerSMB::Admin::Database;
use Moo;
extends 'PGObject::Util::DBAdmin';
use File::Temp;
use App::LedgerSMB::Admin;
use App::LedgerSMB::Admin::Database::Setting;

=head1 NAME

App::LedgerSMB::Admin::Database - Administer LedgerSMB Databases

=head1 SYNOPSIS

Upgrading to 1.4 from 1.3, after updating 1.3 instance to latest:

  use App::LedgerSMB::Admin;
  use App::LedgerSMB::Admin::Database;
  App::LedgerSMB::Admin->add_paths(
     '1.3' => '/usr/local/ledgersmb_1.3',
     '1.4' => '/usr/local/ledgersmb_1.4',
  ); # setting the version paths
  my $db = App::LedgerSMB::Admin::Database->new(
     username  => 'postgres',
     password  => 'secretpassword',
     host      => 'localhost',
     port      => '5432',
     dbname    => 'mycompany',
  );
  if ($db->major_version eq '1.3') {
      $db->reload;
      $db->upgrade_to('1.4');
  }

=head1 VERSION

0.03

=cut

our $VERSION=0.03;

=head1 PROPERTIES INHERITED FROM PGObject::Util::DBAdmin

Please see the docs for PGObject::Util::DBAdmin.

=head2 username 

=head2 password

=head2 host

=head2 port

=head2 dbname

=head1 ADDITIONAL PROPERTIES

=head2 version

Returns the version number of the database.

=cut

has version => (is => 'lazy');

sub _build_version {
    my $self = shift;
    return App::LedgerSMB::Admin::Database::Setting->new(
                                        database    => $self,
                                        setting_key => 'version')->value;
}

=head2 major_version

Major versions are generally understood to be not backwards compatible.  In
LedgerSMB, as with PostgreSQL, major versions are based on the second numbers
in the version, so 1.2, 1.3, and 1.4 are major versions.

=cut

has major_version => (is => 'lazy');

sub _build_major_version {
    my $self = shift;
    my $version = $self->version;
    $version =~ s/\.\d*$//;
    return $version;
}

=head1 METHODS INHERITED

Please see the docs for PGObject::Util::DBAdmin

=head2 create

=head2 connect

=head2 drop

=head2 run_file

=head2 backup

=head2 restore_backup

=head1 NEW METHODS

=head2 load($major_version)

Loads the db schema for the major version requested.

=cut

sub load {
    my ($self, $major_version) = @_;
    eval {
       $self->run_file(
            file => App::LedgerSMB::Admin->path_for($major_version)
                    . "/sql/Pg-database.sql"
       );
    };
    my $sqlpath = App::LedgerSMB::Admin->path_for($major_version) . "/sql/modules";
    return $self->process_loadorder($sqlpath, "$sqlpath/LOADORDER");
}

=head2 reload

Reloads all modules in a LedgerSMB instance.

=cut

sub reload {
    my ($self) = @_;
    my $sqlpath = App::LedgerSMB::Admin->path_for($self->major_version)
                  . '/sql/modules';
    return $self->process_loadorder($sqlpath, "$sqlpath/LOADORDER");
}

=head2 process_loadorder($sql_path, $loadorder_path);

Processes a specific loadorder.  Useful for installing extensions to LedgerSMB

Dies if any SQL files produce errors except from a file starting with "Fixes."

=cut

sub process_loadorder {
    my ($self, $sql_path, $loadorder_path) = @_;
    $sql_path =~ s|/$||;
    open(LOAD, '<', $loadorder_path) || die "Cannot open loadorder: $!";
    for my $line (<LOAD>){
        $line =~ s/(\s*|#.*)//g;
        next unless $line;
        if ($line =~ /^Fixes/){
           eval { $self->run_file(file => "$sql_path/$line") };
        } else {
           $self->run_file(file => "$sql_path/$line");
        }
    }
    $self->process_old_roles() if $self->major_version eq '1.3';
    return 1;
}

=head2 process_old_roles($rolefile)

Processes an old-style (1.3-era) roles file and runes it on the database.

=cut

sub process_old_roles {
    my ($self, $rolefile, %args) = @_;
    $rolefile ||= 'Roles.sql';
    my $sqlpath = App::LedgerSMB::Admin->path_for($self->major_version)
                  . '/sql/modules';
    my $tempdir = $args{tempdir} || $ENV{TEMP} || '/tmp';
    my $temp = File::Temp->new(DIR => $tempdir);
    open ROLES, '<', "$sqlpath/$rolefile";
    for my $line (<ROLES>){
        my $dbname = $self->dbname;
        $line =~ s/<\?lsmb dbname ?>/$dbname/g;
        print $temp $line;
    }
    eval { $self->run_file($temp->filename); };
}

=head2 upgrade_to($major_version)

Upgrades to the major version specified.  Provides an error if the upgrade file
is not found.

=cut

sub upgrade_to {
    my ($self, $major_version) = @_;
    my $up_filename = "lsmb" . $self->major_version . '-' . $major_version
                      . ".sql";
    my $versionpath = App::LedgerSMB::Admin->path_for($major_version);
    die 'No version path registered' unless $versionpath;
    $self->run_file(file => "$versionpath/sql/upgrade/$up_filename");
    $self->new($self->export)->reload;
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

1;	;
