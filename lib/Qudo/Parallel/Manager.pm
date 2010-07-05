package Qudo::Parallel::Manager;
use strict;
use warnings;
use Qudo;
use UNIVERSAL::require;
use Parallel::Prefork;

our $VERSION = '0.01';

sub new {
    my ($class, %args) = @_;

    my $max_workers            = delete $args{max_workers} || 1;
    my $max_request_par_chiled = delete $args{max_request_par_chiled} || 30;
    my $auto_load_worker       = delete $args{auto_load_worker} || 1;
    my $debug                  = delete $args{debug} || 0;

    my $qudo = Qudo->new(%args);

    my $self = bless {
        max_workers            => $max_workers,
        max_request_par_chiled => $max_request_par_chiled,
        debug                  => $debug,
        qudo                   => $qudo,
    }, $class;

    if ($auto_load_worker) {
        for my $worker (@{$qudo->{manager_abilities}}) {
            $self->debug("Setting up the $worker\n");
            $worker->use or die $@
        }
    }

    $self;
}

sub debug {
    my ($self, $msg) = @_;
    warn $msg if $self->{debug};
}

sub run {
    my $self = shift;

    $self->debug("START WORKING : $$\n");

    my $pm = Parallel::Prefork->new({
        max_workers  => $self->{max_workers},
        fork_delay   => 1,
        trap_signals => {
            TERM => 'TERM',
            HUP  => 'TERM',
        },
    });

    while ($pm->signal_received ne 'TERM') {
        $pm->start and next;

        $self->debug("spawn $$\n");

        {
            my $manager = $self->{qudo}->manager;
            my $reqs_before_exit = $self->{max_request_par_chiled};

            $SIG{TERM} = sub { $reqs_before_exit = 0 };

            while ($reqs_before_exit > 0) {
                if ($manager->work_once) {
                    --$reqs_before_exit
                }
            }
        }

        $self->debug("FINISHED $$\n");
        $pm->finish;
    }

    $pm->wait_all_children;
}

1;
__END__

=head1 NAME

Qudo::Parallel::Manager - auto control forking manager process.

=head1 SYNOPSIS

  use Qudo::Parallel::Manager;
  my $manager = Qudo::Parallel::Manager->new(
      databases => [+{
          dsn      => 'dbi:SQLite:/tmp/qudo.db',
          username => '',
          password => '',
      }],
      max_workers            => 5,
      max_request_par_chiled => 30,
      auto_load_worker       => 1,
      debug                  => 1,
  );

=head1 DESCRIPTION

Qudo::Parallel::Manager is

=head1 AUTHOR

Atsushi Kobayashi E<lt>nekokak _at_ gmail _dot_ comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
