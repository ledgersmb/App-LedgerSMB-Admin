#!perl -T
use 5.008;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 6;

BEGIN {
    use_ok( 'App::LedgerSMB::Admin' ) || print "Bail out!\n";
    use_ok( 'App::LedgerSMB::Admin::Database' );
    use_ok( 'App::LedgerSMB::Admin::Database::Setting' );
    use_ok( 'App::LedgerSMB::Admin::Database::Routings' );
    use_ok( 'App::LedgerSMB::Admin::User' );
    use_ok( 'App::LedgerSMB::Admin::Auth' );
}

diag( "Testing App::LedgerSMB::Admin $App::LedgerSMB::Admin::VERSION, Perl $], $^X" );
