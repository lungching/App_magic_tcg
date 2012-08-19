
use Test::More;
use AppMagicTCG::Card;
use Data::Printer;

my $card_app = AppMagicTCG::Card->new();
$card_app->init( { "dsn" => "dbi:SQLite:dbname=db/test.db" } );
$card_app->clear_db();

my %data = (
    name           => 'name1',
    description    => 'description1',
    flavor_text    => 'flavor1',
    type           => 'type1',
    subtype        => 'subtype1',
    power          => 1,
    toughness      => 2,
    generic_mana   => 3,
    specific_mana  => 'G',
    converted_mana => 4,
    edition        => 'edition1',
    rarity         => 'rarity1',
    quantity       => 5,
    notes          => 'notes1',
);

my $card = $card_app->get_db_info( 'name1' );
is $card->{name}, undef, "No data in db so nothing returned";

my $info = $card_app->save_data( \%data );

$card = $card_app->get_db_info( 'name1');
is $card->{name}, $data{name}, "One card found";

for my $col ( keys %data ) {
    is $card->{ $col }, $data{ $col }, "Column $col correct";
}

$card->{description} = 'description2';

my $info = $card_app->save_data( $card );

$card = $card_app->get_db_info( 'name1' );
is $card->{name}, $data{name}, "One card found";
is $card->{description}, 'description2', "Description updated";


done_testing();
