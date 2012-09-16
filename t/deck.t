use Mojo::Base -strict;

use AppMagicTCG;
use AppMagicTCG::Card;
use Test::More;
use Test::Mojo;

my $deck_app = AppMagicTCG::Deck->new();
$deck_app->init( { "dsn" => "dbi:SQLite:dbname=db/test.db" } );
$deck_app->clear_db();

my $t = Test::Mojo->new( AppMagicTCG->new( conf_file => 'conf/db_test_conf.json' ) );
$t->get_ok('/')->status_is(200)->content_like(qr/Mojolicious/i);
$t->get_ok('/deck')->status_is(200)->content_like(qr/<input type="text" name="deck_name"/i);

my $params = {
    deck_name => 'Test Deck',
};

$t->post_form_ok('/deck' => { deck_name => $params->{deck_name}, new_deck => 1, })
    ->status_is(200)
    ->content_like(qr/$params->{name}/, 'name');

# $t->post_form_ok('/card' => { %{ $params }, save => 1  })
    # ->status_is(200)
    # ->content_like(qr/$params->{notes}/, 'notes')
    # ->content_like(qr/Saved $params->{name} Successfully. /);

done_testing();
