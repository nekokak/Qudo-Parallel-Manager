#! /usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;

while (1) {
    my $sock = IO::Socket::INET->new(
        PeerHost => '127.0.0.1',
        PeerPort => 90000,
        Proto    => 'tcp',
    ) or die 'can not connect admin port.';

    my $status = $sock->getline;
    print $status, "\n";
    $sock->close;

    sleep(1);
}

