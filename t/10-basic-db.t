use Test::More;
use Test::Exception;
use App::LedgerSMB::Admin;
use App::LedgerSMB::Admin::Database;

plan skip_all => 'DB_TESTING is not set' unless $ENV{DB_TESTING};
plan tests => 8;

ok(App::LedgerSMB::Admin->add_paths(
      mock1 => 't/data/mock1',
      mock2 => 't/data/mock2'
  ), 'Added paths');

my $db;

ok($db = App::LedgerSMB::Admin::Database->new(
      username => 'postgres',
      host     => 'localhost',
      dbname   => 'app_ledgersmb_test',
   ), 'New database management object created'
);

eval { $db->drop };

dies_ok { $db->major_version } "can't get major version on nonexistent db";
ok($db = $db->new($db->export), 'Copied db credentials into new object');

ok($db->create, 'Created database');
ok($db->run_file(file => App::LedgerSMB::Admin->path_for('mock1') . "/sql/Pg-database.sql"), 'Loaded base schema');

lives_ok {$db->major_version} "Lived when calling major version this time.";
is($db->major_version, '0.1', 'Correct major version');

