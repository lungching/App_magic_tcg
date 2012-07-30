use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('AppMagicTCG');
$t->get_ok('/')->status_is(200)->content_like(qr/Mojolicious/i);
$t->get_ok('/card')->status_is(200)->content_like(qr/<input type="text" name="card_name"/i);

done_testing();
