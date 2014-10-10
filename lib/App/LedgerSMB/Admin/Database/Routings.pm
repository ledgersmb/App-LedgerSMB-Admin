package App::LedgerSMB::Admin::Database::Routings;
use Dancer ':syntax';
use Dancer::Serializer;
use Dancer::Plugin::Ajax;
use Template;

=head1 NAME

App::LedgerSMB::Admin::Database::Routings - Dancer App for LSMB DB Admin

=cut

=head1 URL LAYOUT

All urls occur in the /lsmbadmin/1.0/ path from the document root.

=cut

prefix '/lsmbadmin/1.0';

=head2 Per Server URLs

The server urls are then parameterized with host and port.

For each server the following resources are present:

=over

=item dbs - list databases (get only)

=item new - new database

=item globals - backup of server globals (put to restore)

=back

get retrieves information, post updates the information.

The complete urls then become, for a server at localhost and a port of 5432, 
off a base of:

 /lsmbadmin/1.0/localhost/5432/

So the database list would be found at

 /lsmbadmin/1.0/localhost/5432/dbs

=cut

get  '/:host/:port/dbs'     => sub { template 'dblist'  => _list_dbs() };
ajax  '/:host/:port/dbs'    => sub { to_json(_lsmb_dbs()) };
get  '/:host/:port/new'     => sub { template 'new_db'  => {} };
post '/:host/:port/new'     => sub { template 'db_info' => _createdb() };
ajax  '/:host/:port/new'    => sub { to_json(createdb()) };
get  '/:host/:port/globals' => sub { _backup_globals() };
put  '/:host/:port/globals' => sub { template 'restored' => _restore_globals()};
ajax '/:host/:port/globals' => sub { to_json(_restore_globals()) };

=head2 Per Database URLs

=cut

get  '/:host/:port/db/:dbname/' => sub { template 'db_info' => _db_info(); };
post '/:host/:port/db/:dbname/' => \&_reload_db;
put  '/:host/:port/db/:dbname/' => \&_reload_db;
put  '/:host/:port/db/:dbname/*.sql' => \&_run_file;
post '/:host/:port/db/:dbname/*.sql' => \&_run_file;
get  '/:host/:port/db/:dbname/backup/*.*' => \&_backup_db;
put  '/:host/:port/db/:dbname/backup/*.*' => \&_restore_backup;
post '/:host/:port/db/:dbname/backup/*.*' => \&_restore_backup;


sub _list_dbs {
    my $db = authenticate(
              host   => param('host'), 
              port   => param('port'),
              dbname => 'postgres'
    );
    return $db->list_dbs;
}

sub _createdb {
    my $db = authenticate(
              host   => param('host'), 
              port   => param('port'),
              dbname => 'postgres'
    );
    my $newdb = App::LedgerSMB::Admin::Database->new(
           $db->export, dbname => param('dbname')
    );
    $newdb->create;
    $newdb->load;
    return $newdb->list_dbs;
}

sub _backup_globals {
}

sub _restore_globals {
}

sub _reload_db {
}

sub _backup_db {
}

sub _restore_db {
}

sub _run_file {
}

1;
