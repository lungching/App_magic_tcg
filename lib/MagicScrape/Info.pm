package MagicScrape::Info;

use strict;
use warnings;

use v5.10;
use WWW::Mechanize::Query;
use Data::Dumper;
use Data::Printer;

my $query_url = 'http://magiccards.info/query?v=card&s=cname&q=';

sub get_general_info {
    my $name = shift;
    my $doc_root = shift;

    return if ! $name;

    my $card_entry = card_img_name( $name );

    my $agent = WWW::Mechanize::Query->new();
    $agent->get( $query_url . $name );

    if ( $agent->content =~ /Your query did not match any cards/ ) {
        warn "$name did not match anything";
        return;
    }

    my $images = $agent->images();
    my ($real_name, $image_path) = save_image($name, $card_entry, $doc_root, $images );
    $image_path =~ s/.*(card_images.*)/$1/;

    # /html/body/table[3]/tr/td[2]/p[2]/b
    my $container   = $agent->find('html body table')->[3]->find('tr td');
    my $description = $container->[1]->find('p')->[1]->find('b')->[0]->text;
    my $flavor      = $container->[1]->find('p')->[2]->find('i')->[0]->text;
    my $meta        = $container->[1]->find('p')->[0]->text;

    # not always at the same path so lets just us a regex
    # ultimately looking for something like 'Dark Ascension (Uncommon)'
    my $edition_html = $container->[2]->to_xml();
    my ($edition, $rarity) = $edition_html =~ /Editions:<\/b><\/u><br\s\/>\s*
                                                <img.*\s*
                                                <b>([^(]+)\((.+)\)    # search for stuff the is not a '(' then grab stuff inside the ()'s
                                              /xms;
    $edition =~ s/ $//;

    # E.G. - Creature — Beast 5/5, 5GGG (8)
    my ($type, $subtype, $general_mana, $specific_mana, $converted_mana) = $meta =~ /^(\w+)        # type
                                                                                      (?:[ ].[ ])? # delimiter if the there's a subtype
                                                                                      ([^,]*)?     # subtype
                                                                                      ,[ ]
                                                                                      (\d*)        # general mana cost
                                                                                      (\w+)        # specific mana cost
                                                                                      [ ]
                                                                                      \((\d+)\)    # converted mana cost
                                                                                    /x;
    my ($power, $toughness);

    if ( $subtype =~ /\// ) {
    ($power, $toughness) = $subtype =~ / (.?.)\/(.?.)/;
    $subtype =~ s/ (.?.\/.?.)//;
    }

    my $info = {
        real_name      => $real_name,
        image_path     => $image_path,
        description    => $description,
        flavor_text    => $flavor,
        type           => $type,
        subtype        => $subtype,
        general_mana   => $general_mana,
        specific_mana  => $specific_mana,
        converted_mana => $converted_mana,
        power          => $power,
        toughness      => $toughness,
        edition        => $edition,
        rarity         => $rarity,
    };

    return ( $info );
}

sub save_image {
    my (
        $name,
        $card_entry,
        $doc_root,
        $images,
    ) = @_;

    my $agent = WWW::Mechanize::Query->new();
    my ($card_img) = grep { $_->alt =~ /$name/i; } @$images;

    warn "could not find card image - " . Dumper($images) unless $card_img;

    return undef unless $card_img;
    my $img_url = $card_img->URI;
    my $real_name = $card_img->alt;

    my $file = 'public/card_images/' . $card_entry . '.jpeg';
    my $target_file = $doc_root . $file;

    # only save the file if it doesn't exist already
    $agent->get( $img_url, ':content_file' => $target_file ) if ! -e $target_file;

    return ($real_name, $target_file);
}

sub card_img_name {
    my $orig_name = shift;

    my $card_entry = $orig_name;
    $card_entry =~ s/ /_/g;
    $card_entry =~ s/'//g;
    $card_entry =~ s/,//g;
    $card_entry = lc($card_entry);

    return $card_entry;
}

1;
