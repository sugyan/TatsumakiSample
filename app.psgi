#!/usr/bin/env perl
use strict;
use warnings;

use FindBin::libs;
use IndexHandler;
use StreamHandler;
use Tatsumaki::Application;

my $app = Tatsumaki::Application->new([
    '/'       => 'IndexHandler',
    '/stream' => 'StreamHandler',
]);

return $app->psgi_app;
