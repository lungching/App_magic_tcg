package AppMagicTCG::Card;
use Mojo::Base 'Mojolicious::Controller';

use MagicScrape::Info;
use DBD::SQLite;

# This action will render a template
sub info {
    my $self = shift;

    my $info;

    $self->stash( saved_result => undef );
    if ( $self->param('save') ) {
        my $saved_state;
        my $saved_result = $self->save_data();
        $self->stash( saved_result => $saved_result );
    }

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

sub save_data {
    my $self = shift;
    my $dbh = DBI->connect("dbi:SQLite:dbname=db/magic.db","","");

    my $sth = $dbh->prepare(q{
        INSERT INTO card
        (
            name,
            description,
            flavor_text,
            card_type,
            card_subtype,
            power,
            toughness,
            generic_mana,
            specific_mana,
            converted_mana,
            edition,
            rarity,
            quantity
        )
        VALUES
        (
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?
        )
    });

    $sth->execute(
        $self->param('card_name') || '',
        $self->param('card_description') || '',
        $self->param('card_flavor') || '',
        $self->param('type') || '',
        $self->param('subtype') || '',
        $self->param('power') || '',
        $self->param('toughness') || '',
        $self->param('generic_mana') || '',
        $self->param('specific_mana') || '',
        $self->param('converted_mana') || '',
        $self->param('edition') || '',
        $self->param('rarity') || '',
        $self->param('quantity') || '',
    );

    if ( $sth->err ) {
        return $sth->errstr;
    }
    else {
        return 1;
    }
}

1;
