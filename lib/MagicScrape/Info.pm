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

    my $card_entry = $name;
    $card_entry =~ s/ /_/g;
    $card_entry =~ s/'//g;
    $card_entry = lc($card_entry);

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
    my $container   = $agent->find('html body table')->[3]->find('tr td')->[1];
    my $description = $container->find('p')->[1]->find('b')->[0]->text;
    my $flavor      = $container->find('p')->[2]->find('i')->[0]->text;

    my %info = (
        real_name => $real_name,
        image_path => $image_path,
        description => $description,
        flavor => $flavor,
    );

    return ( \%info );
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

1;
