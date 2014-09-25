use Dancer ':syntax';
use Template;

# Databases

get  '/lsmbadmin/1.0/:host/:port/' => \&list_dbs;
get  '/lsmbadmin/1.0/:host/:port/newdb/' => sub { template 'new_db' => {} };
post '/lsmbadmin/1.0/:host/:port/newdb/' => \&createdb;
put  '/lsmbadmin/1.0/:host/:port/newdb/' => \&createdb;
get  '/lsmbadmin/1.0/:host/:port/globals/' => \&backup_globals;
post '/lsmbadmin/1.0/:host/:port/globals/' => \&restore_globals;
put  '/lsmbadmin/1.0/:host/:port/globals/' => \&restore_globals;
get  '/lsmbadmin/1.0/:host/:port/db/:dbname' => sub {
                                                  template 'db_info' =>
                                                            db_info();
                                              };
post '/lsmbadmin/1.0/:host/:port/db/:dbname' => \&reload_db;
put  '/lsmbadmin/1.0/:host/:port/db/:dbname' => \&reload_db;
get  '/lsmbadmin/1.0/:host/:port/db/:dbname/backup' => \&backup_db;
put  '/lsmbadmin/1.0/:host/:port/db/:dbname/backup' => \&restore_backup;
post '/lsmbadmin/1.0/:host/:port/db/:dbname/backup' => \&restore_backup;

# subs

sub get_db {
}

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

1;
