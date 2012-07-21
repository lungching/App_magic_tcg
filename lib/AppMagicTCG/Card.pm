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
    );

    $self->render();
}

1;
