use strict;
use warnings;
use lib './t/lib';
use Test::More tests => 3;
use Qudo;
use Qudo::Test;
use Qudo::Parallel::Manager;

my $test_db = 'palallel_manager';
Qudo::Test::setup_dbs([$test_db]);

my $qudo = Qudo->new(
    databases => [+{
        dsn => "dbi:SQLite:./test_qudo_${test_db}.db",
    }],
);
$qudo->enqueue('Worker::Test', {arg => 'foo'});

my $manager = Qudo::Parallel::Manager->new(
    databases => [+{
        dsn => "dbi:SQLite:./test_qudo_${test_db}.db",
    }],
    manager_abilities => [qw/Worker::Test/],
    debug => 0,
);

ok $manager;

is $qudo->job_count->{'dbi:SQLite:./test_qudo_palallel_manager.db'}, 1;

my $ppid = $$;
if ( fork ) {
    $manager->run;
    wait;
} else {
    sleep(1);
    kill 'TERM', $ppid;
}

is $qudo->job_count->{'dbi:SQLite:./test_qudo_palallel_manager.db'}, 0;

Qudo::Test::teardown_dbs([$test_db]);

