package App::LedgerSMB::Admin::Database::Routings;
use Dancer ':syntax';
use Template;

=head1 NAME

App::LedgerSMB::Admin::Database::Routings - Dancer App for LSMB DB Admin

=cut

# Databases

get  '/lsmbadmin/1.0/:host/:port/list.*' => \&_list_dbs;
get  '/lsmbadmin/1.0/:host/:port/new.html' => sub { template 'new_db' => {} };
post '/lsmbadmin/1.0/:host/:port/new.*' => \&_createdb;
put  '/lsmbadmin/1.0/:host/:port/new.*' => \&_createdb;
get  '/lsmbadmin/1.0/:host/:port/globals/*.*' => \&_backup_globals;
post '/lsmbadmin/1.0/:host/:port/globals/*.*' => \&_restore_globals;
put  '/lsmbadmin/1.0/:host/:port/globals/*.*' => \&_restore_globals;
get  '/lsmbadmin/1.0/:host/:port/db/:dbname/' => sub {
                                                  template 'db_info' =>
                                                            db_info();
                                              };
post '/lsmbadmin/1.0/:host/:port/db/:dbname/' => \&reload_db;
put  '/lsmbadmin/1.0/:host/:port/db/:dbname/' => \&reload_db;
put  '/lsmbadmin/1.0/:host/:port/db/:dbname/*.sql' => \&run_file;
post '/lsmbadmin/1.0/:host/:port/db/:dbname/*.sql' => \&run_file;
get  '/lsmbadmin/1.0/:host/:port/db/:dbname/backup/*.*' => \&backup_db;
put  '/lsmbadmin/1.0/:host/:port/db/:dbname/backup/*.*' => \&restore_backup;
post '/lsmbadmin/1.0/:host/:port/db/:dbname/backup/*.*' => \&restore_backup;

# subs

sub list_dbs {
}

sub createdb {
}

sub backup_globals {
}

sub restore_globals {
}

sub reload_db {
}

sub backup_db {
}

sub restore_db {
}

sub run_file {
}

1;
