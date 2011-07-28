package StreamHandler;
use strict;
use warnings;
use parent 'Tatsumaki::Handler';
__PACKAGE__->asynchronous(1);

use Tatsumaki::MessageQueue;

sub get {
    my ($self) = @_;

    my $mq = Tatsumaki::MessageQueue->instance(1);
    my $client_id = $self->request->param('client_id');
    $mq->poll_once(
        $client_id,
        sub {
            my @events = @_;
            $self->write(\@events);
            $self->finish;
        },
    );
}

1;
