package AppMagicTCG::Card;
use Mojo::Base 'Mojolicious::Controller';

use MagicScrape::Info;

# This action will render a template
sub info {
    my $self = shift;

    my $info;

    my $doc_root = '/home/mburns/projects/App_magic_tcg/';  # hard code for now TODO have the server find this
    my $card_name = $self->param('card_name');

    if ( $card_name ) {
        $info = MagicScrape::Info::get_general_info( $card_name, $doc_root );
    }

    $self->stash(
        card_name        => $info->{real_name},
        card_description => $info->{description},
        card_flavor      => $info->{flavor},
        image_path       => $info->{image_path},
        type             => $info->{type},
        subtype          => $info->{subtype},
        mana             => $info->{general_mana} . $info->{specific_mana},
        converted_mana   => $info->{converted_mana},
        power            => $info->{power},
        toughness        => $info->{toughness},
        edition          => $info->{edition},
        rarity           => $info->{rarity},
    );

    $self->render();
}

1;
