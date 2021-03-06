
use Test::More;

use MagicScrape::Info;

my $info = MagicScrape::Info::get_general_info("Butcher's Cleaver", '/home/mburns/projects/App_magic_tcg/');

is $info->{real_name}, "Butcher's Cleaver", "Got real name";
is $info->{image_path}, 'card_images/butchers_cleaver.jpeg', "Got image path";
is $info->{description}, 'Equipped creature gets +3/+0. As long as equipped creature is a Human, it has lifelink. Equip {3}', 'Got description';
is $info->{flavor_text}, 'Outside the safety of Thraben, there is little distinction between tool and weapon.', 'Got flavor';
is $info->{type}, 'Artifact', "Got type";
is $info->{subtype}, 'Equipment', "Got subtype";
is $info->{generic_mana}, 3, "Got general mana";
is $info->{specific_mana}, undef, "No specific mana";
is $info->{converted_mana}, 3, "Got converted mana";
is $info->{edition}, 'Innistrad', "Got edtion";
is $info->{rarity}, 'Uncommon', "Got rarity";

done_testing();
