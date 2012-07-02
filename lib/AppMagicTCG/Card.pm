package AppMagicTCG::Card;
use Mojo::Base 'Mojolicious::Controller';

use MagicScrape::Info;

# This action will render a template
sub info {
    my $self = shift;

    my (
        $card_name,
        $card_description,
        $card_flavor,
        $image_path,
    );

    my $doc_root = '/home/mburns/projects/App_magic_tcg/';  # hard code for now TODO have the server find this
    $card_name = $self->param('card_name');

    if ( $card_name ) {
        (
            $card_name,
            $image_path,
            $card_description,
            $card_flavor,
        ) = MagicScrape::Info::get_general_info( $card_name, $doc_root );
    }

    $self->stash(
        card_name        => $card_name,
        card_description => $card_description,
        card_flavor      => $card_flavor,
        image_path       => $image_path,
    );

    $self->render();
}

1;
