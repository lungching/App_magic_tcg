use Mojo::Base -strict;

use AppMagicTCG;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new( AppMagicTCG->new( conf_file => 'conf/db_test_conf.json' ) );
$t->get_ok('/')->status_is(200)->content_like(qr/Mojolicious/i);
$t->get_ok('/card')->status_is(200)->content_like(qr/<input type="text" name="card_name"/i);

my $params = {
    card_name      => 'Craterhoof Behemoth',
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
    notes          => '',
};

$t->post_form_ok('/card' => { card_name => 'Craterhoof Behemoth' })
    ->status_is(200)
    ->content_like(qr/$params->{card_name}/)
    ->content_like(qr/$params->{description}/)
    ->content_like(qr/$params->{flavor_text}/)
    ->content_like(qr/$params->{type}/)
    ->content_like(qr/$params->{edition}/)
    ->content_like(qr/$params->{rarity}/);

$t->post_form_ok('/card' => { %{ $params }, save => 1  })
    ->status_is(200)
    ->content_like(qr/Saved $params->{card_name} Successfully. /);

done_testing();
