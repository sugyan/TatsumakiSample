package IndexHandler;
use strict;
use warnings;
use parent 'Tatsumaki::Handler';

use Tatsumaki::MessageQueue;

sub get {
    my ($self) = @_;

    my $mq = Tatsumaki::MessageQueue->instance(1);
    $mq->publish({
        type => 'message',
        timestamp => scalar localtime,
        useragent => $self->request->user_agent,
    });
    $self->render('index.html');
}

1;
