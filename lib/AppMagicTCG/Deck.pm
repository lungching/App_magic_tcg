package AppMagicTCG::Deck;
use Mojo::Base 'Mojolicious::Controller';

use DBD::SQLite;
use Data::Printer;
use MagicScrape::Info;
use Carp qw( croak );

my $DBH;
my $doc_root = '/home/mburns/projects/App_magic_tcg/';  # hard code for now TODO have the server find this

sub init {
    my (
        $class,
        $config,
    ) = @_;

    croak "No dsn was passed!" unless $config && $config->{dsn};

    $DBH = DBI->connect( $config->{dsn} ) unless $DBH;
}

sub admin {
    my $self = shift;

    my $info;

    $self->stash( error => '' );

    if ( $self->param('new_deck') ) {
        $self->new_deck();
    }
    elsif ( $self->param('search') ) {
        my $deck_name = search_for_deck($self->param('deck_id'));

        if ( $deck_name ) {
            $self->param( deck_name => $deck_name );
            $self->show_deck();
        }
        else {
            $self->stash('error' => 'Could not find deck ' . $self->param('deck_name') . '.');
        }
    }
    elsif ( $self->param('save') ) {
        my $saved_result = $self->save_deck_info();
        $self->stash( saved_result => $saved_result );
        $self->show_deck();
    }
    elsif ( $self->param('submit_new_card') ) {
        my $saved_result = $self->add_card();
        $self->stash( saved_result => $saved_result );
        $self->show_deck();
    }
    elsif ( $self->param('delete_card_submit') ) {
        my $saved_result = $self->delete_card();
        $self->stash( saved_result => $saved_result );
        $self->show_deck();
    }
    elsif ( $self->param('play') ) {
        $self->show_play_deck();
    }
}

sub search_for_deck {
    my $id = shift;

    my @found = $DBH->selectrow_array("SELECT name FROM deck WHERE deck_id = ?", undef, $id);

    return $found[0];
}

sub new_deck {
    my $self = shift;

    ### TODO make sure the deck name doesn't exist
    my $sth = $DBH->prepare("INSERT INTO deck (name) VALUES ( ? )");

    $sth->execute( $self->param('deck_name') );

    if ( $sth->err ) {
        $self->stash( error => "Database error - " . $sth->errstr );
    }
    else {
        $self->stash( 'new_deck' => "Successfully created deck " . $self->param('deck_name') . '.');
        $self->show_deck;
    }
}

sub show_deck {
    my $self = shift;

    my $info = get_deck_info( $self->param('deck_name') );
    my $card_list = get_card_list();

    $self->stash(
        deck_id      => $info->{deck_id},
        deck_name    => $info->{name},
        notes        => $info->{notes},
        saved_result => '',
        cards        => $info->{cards},
        sideboard    => $info->{sideboard},
        card_list    => $card_list,
    );

    $self->render('deck/detail');
}

sub show_play_deck {
    my $self = shift;

    my ($deck_name) = $DBH->selectrow_array("SELECT name FROM deck WHERE deck_id = ?", undef, $self->param('deck_id'));
    $self->param('deck_name', $deck_name);

    my $info = get_deck_info( $deck_name );
    my $image_list = $self->get_images();

    $self->stash(
        deck_name => $info->{name},
        images    => $image_list,
    );

    $self->render('deck/play');
}


# info = {
#   card_name => <name>,
#   card_id => <id>,
#   quantity => <num>,
#   < cards | sideboard > => { <type e.g. Creature > => [
#       {
#           card_name => <name>,
#           card_id => <id>,
#           quantity => <quantity in deck>,
#           img_src => <path to image>,
#           map_id => <map_id>,
#           specific_mana => <integer>,
#           generic_mana => [ <img src>, ... ],
#       },
#       ...
#   ],
# }

sub get_deck_info {
    my $name = shift;

    my $info = $DBH->selectrow_hashref("SELECT * FROM deck WHERE name = ?", undef, $name);

    my $mapping = $DBH->selectall_arrayref("
        SELECT
            c.name,
            c.card_id,
            m.quantity,
            m.is_sideboard,
            m.map_id,
            c.type,
            c.generic_mana,
            c.specific_mana
        FROM
            deck d,
            deck_card_map m,
            card c
        WHERE
            d.deck_id = m.deck_id
            AND c.card_id = m.card_id
            AND d.deck_id = ?
    ", undef, $info->{deck_id});

    my %cards;
    my %sideboard;
    for my $card ( @$mapping ) {
        my $card_img = "card_images/" . MagicScrape::Info::card_img_name( $card->[0] ) . ".jpeg";
        my $specific_mana;
        my $card_info = {
            card_name => $card->[0],
            card_id => $card->[1],
            quantity => $card->[2],
            img_src => $card_img,
            map_id => $card->[4],
            generic_mana => $card->[6],
            specific_mana => $specific_mana,
        };
        if ( $card->[3] ) {
            push @{ $sideboard{$card->[5]} }, $card_info;
        }
        else {
            push @{ $cards{ $card->[5]} }, $card_info;
        }
    }

    $info->{cards}     = \%cards;
    $info->{sideboard} = \%sideboard;

    return $info;
}

sub save_deck_info {
    my $self = shift;

    my $sth = $DBH->prepare("
        UPDATE deck
        SET
            name = ?,
            notes = ?
        WHERE
            deck_id = ?
    ");

    $sth->execute( $self->param('deck_name'), $self->param('notes'), $self->param('deck_id') );

    if ( $sth->err ) {
        return $sth->errstr;
    }
    else {
        return 1;
    }
}

sub get_card_list {
    my $sth = $DBH->prepare("SELECT card_id, name FROM card ORDER BY name");
    $sth->execute();
    my @list;

    while ( my $row = $sth->fetchrow_hashref ) {
        push @list, { name => $row->{name}, value => $row->{card_id}, };
    }

    return \@list;
}

sub get_deck_list {
    my $sth = $DBH->prepare("SELECT deck_id, name FROM deck ORDER BY name");
    $sth->execute();
    my @list;

    while ( my $row = $sth->fetchrow_hashref ) {
        push @list, { name => $row->{name}, value => $row->{deck_id}, };
    }

    return \@list;
}

sub add_card {
    my $self = shift;

    my $deck_id = $self->param('deck_id');
    my $card_id = $self->param('add_card');
    my $qty     = $self->param('quantity') || 0;
    my $is_sb   = $self->param('is_sideboard') ? 1 : 0;

    return "Need both a deck id and a card id" unless $deck_id && $card_id;

    my $sth = $DBH->prepare("INSERT INTO deck_card_map (deck_id, card_id, quantity, is_sideboard) VALUES (?, ?, ?, ?)");
    $sth->execute( $deck_id, $card_id, $qty, $is_sb );

    if ( $sth->err ) {
        return $sth->errstr;
    }
    else {
        return 1;
    }
}

sub delete_card {
    my $self = shift;

    my @map_ids = $self->param('delete_card');

    return unless scalar @map_ids;

    my $sth = $DBH->prepare("delete from deck_card_map where map_id = ?");

    for my $map_id ( @map_ids ) {
        $sth->execute( $map_id);
    }

    if ( $sth->err ) {
        return $sth->errstr;
    }
    else {
        return 1;
    }
}


sub get_images {
    my $self = shift;

    my $info = get_deck_info( $self->param('deck_name') );
    my @images;

    for my $card ( @{ $info->{cards} } ) {
        my $card_img = MagicScrape::Info::card_img_name( $card->{card_name} );
        for (1..$card->{quantity}) {
            push @images, "card_images/$card_img.jpeg";
        }
    }

    return \@images;
}

1;
