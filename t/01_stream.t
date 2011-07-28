use strict;
use warnings;
use Test::More tests => 9;

use AnyEvent;
use AnyEvent::HTTP;
use FindBin;
use Furl;
use JSON::XS 'decode_json';
use Test::TCP qw/empty_port wait_port/;
use Try::Tiny;
use Plack::Runner;
use Proc::Guard;

my ($tatsumaki, $port) = prepare();

my $rand = rand 1;
my $count = 0;

my $polling; $polling = sub {
    my $cv = AE::cv;
    my $w = http_request
        GET => "http://localhost:${port}/stream?client_id=${rand}",
            want_body_handle => 1,
            sub {
                my ($hdl, $hdr) = @_;

                is($hdr->{Status}, 200, '/stream');
                $hdl->push_read(
                    json => sub {
                        my (undef, $json) = @_;
                        is($json->[0]{useragent}, "agent${count}", 'useragent');
                        $cv->send;
                    }
                );
            };
    $cv->recv;
    return if ($count >= 3);
    $polling->();
};

my $cv = AE::cv;
my $w = AE::timer 1, 1, sub {
    $count++;
    my $res = Furl->new(agent => "agent${count}")->get("http://localhost:${port}/");
    ok($res->is_success, '/');
    $cv->send if $count >= 3;
};
$polling->();
$cv->recv;


sub prepare {
    my $psgi = File::Spec->catfile($FindBin::Bin, '..', 'app.psgi');
    my $port = empty_port();
    my $async = proc_guard(
        sub {
            my $runner = Plack::Runner->new;
            $runner->parse_options('-p', $port, '-s', 'Twiggy', $psgi);
            $runner->run;
        }
    );
    wait_port($port);

    return ($async, $port);
}
