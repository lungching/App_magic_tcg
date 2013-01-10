use Mojo::Base -strict;

use AppMagicTCG;
use AppMagicTCG::Card;
use Test::More;
use Test::Mojo;

my $card_app = AppMagicTCG::Card->new();
$card_app->init( { "dsn" => "dbi:SQLite:dbname=db/test.db" } );
$card_app->clear_db();

my $t = Test::Mojo->new( AppMagicTCG->new( conf_file => 'conf/db_test_conf.json' ) );
$t->get_ok('/')->status_is(200)->content_like(qr/<title>Magic<\/title>/);
$t->get_ok('/card')->status_is(200)->content_like(qr/<input type="text" name="name"/i);

my $params = {
    name           => 'Craterhoof Behemoth',
    description    => 'Haste When Craterhoof Behemoth enters the battlefield, creatures you control gain trample',
    flavor_text    => 'Its footsteps of today are the lakes of tomorrow.',
    type           => 'Creature',
    subtype        => 'Beast',
    power          => 5,
    toughness      => 5,
    generic_mana   => 5,
    specific_mana  => 'GGG',
    converted_mana => 8,
    edition        => 'Avacyn Restored',
    rarity         => 'Mythic Rare',
    quantity       => 0,
    notes          => 'this is a note',
};

$t->post_form_ok('/card' => { name => 'Craterhoof Behemoth' })
    ->status_is(200)
    ->content_like(qr/$params->{name}/, 'name')
    ->content_like(qr/$params->{description}/, 'description')
    ->content_like(qr/$params->{flavor_text}/, 'flavor')
    ->content_like(qr/$params->{type}/, 'type',)
    ->content_like(qr/$params->{edition}/, 'edition')
    ->content_like(qr/$params->{rarity}/, 'rarity');

$t->post_form_ok('/card' => { %{ $params }, save => 1  })
    ->status_is(200)
    ->content_like(qr/$params->{notes}/, 'notes')
    ->content_like(qr/Saved $params->{name} Successfully. /);

done_testing();
