package MagicScrape::Info;

use strict;
use warnings;

use WWW::Mechanize;

my $query_url = 'http://magiccards.info/query?v=card&s=cname&q=';

sub get_general_info {
    my $name = shift;
    my $doc_root = shift;

    return if ! $name;

    my $card_entry = $name;
    $card_entry =~ s/ /_/g;
    $card_entry =~ s/'//g;
    $card_entry = lc($card_entry);

    my $agent = WWW::Mechanize->new();
    $agent->get( $query_url . $name );

    if ( $agent->content =~ /Your query did not match any cards/ ) {
        warn "$name did not match anything";
        return;
    }

    my $images = $agent->images();
    my $image_path = save_image($name, $card_entry, $doc_root, $images );
    $image_path =~ s/.*(card_images.*)/$1/;

    my $description = get_description( $agent->content() );
    my $flavor = get_flavor( $agent->content() );
    my $real_name = $name;
    # my $real_name = get_name( $agent->content() );

    return ( $real_name, $image_path, $description, $flavor );
}

sub save_image {
    my (
        $name,
        $card_entry,
        $doc_root,
        $images,
    ) = @_;

    my $agent = WWW::Mechanize->new();
    my ($card_img) = grep { $_->alt =~ /$name/i; } @$images;

    warn "could not find card image - " . Dumper($images) unless $card_img;

    return undef unless $card_img;
    my $img_url = $card_img->URI;

    my $file = 'public/card_images/' . $card_entry . '.jpeg';
    my $target_file = $doc_root . $file;
warn "target file: $target_file";
    $agent->get( $img_url, ':content_file' => $target_file );

    return $target_file;
}

sub get_description {
}

sub get_flavor {
}
