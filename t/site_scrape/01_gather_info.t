
use Test::More tests => 11;

use MagicScrape::Info;

my $info = MagicScrape::Info::get_general_info("Butcher's Cleaver", '/home/mburns/projects/App_magic_tcg/');

is $info->{real_name}, "Butcher's Cleaver", "Got real name";
is $info->{image_path}, 'card_images/butchers_cleaver.jpeg', "Got image path";
is $info->{description}, 'Equipped creature gets +3/+0. As long as equipped creature is a Human, it has lifelink. Equip {3}', 'Got description';
is $info->{flavor}, 'Outside the safety of Thraben, there is little distinction between tool and weapon.', 'Got flavor';
is $info->{type}, 'Artifact', "Got type";
is $info->{subtype}, 'Equipment', "Got subtype";
is $info->{general_mana}, 3, "Got general mana";
is $info->{specific_mana}, '', "No specific mana";
is $info->{converted_mana}, 3, "Got converted mana";
is $info->{edition}, 'Innistrad', "Got edtion";
is $info->{rarity}, 'Uncommon', "Got rarity";
