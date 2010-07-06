#! /usr/bin/env perl
use strict;
use warnings;
use Qudo::Parallel::Manager;

my $m = Qudo::Parallel::Manager->new(
    databases => [+{
        dsn      => 'dbi:mysql:qudo',
        username => 'root',
        password => '',
    }],
    manager_abilities  => [qw/Worker::Test/],
    min_spare_workers  => 10,
    max_spare_workers  => 50,
    max_workers        => 50,
    work_delay         => 3,
    debug => 1,
);

$m->run;
