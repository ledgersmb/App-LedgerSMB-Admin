use 5.010;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'App::LedgerSMB::Admin',
    AUTHOR           => q{Chris Travers <chris@efficito.com>},
    VERSION_FROM     => 'lib/App/LedgerSMB/Admin.pm',
    ABSTRACT_FROM    => 'lib/App/LedgerSMB/Admin.pm',
    LICENSE          => 'BSD',
    PL_FILES         => {},
    EXE_FILES        => [ 'bin/lsmb_reload', 'bin/lsmb_createdb' ],
    MIN_PERL_VERSION => 5.010,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'App-LedgerSMB-Admin-*' },
);
