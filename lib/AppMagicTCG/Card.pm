package AppMagicTCG::Card;
use Mojo::Base 'Mojolicious::Controller';

use MagicScrape::Info;
use DBD::SQLite;
use Data::Printer;
use Carp qw( croak );

my $DBH;

sub init {
    my (
        $class,
        $config,
    ) = @_;

    croak "No dsn was passed!" unless $config && $config->{dsn};

    $DBH = DBI->connect( $config->{dsn} ) unless $DBH;
}

sub info {
    my $self = shift;

    my $info;

    $self->stash( saved_result => undef );
    if ( $self->param('save') ) {
        my $saved_state;
        my %card_info;
        for my $name ( $self->param ) {
            $card_info{ $name } = $self->param( $name );
        }
        my $saved_result = $self->save_data( \%card_info );
        $self->stash( saved_result => $saved_result );
    }

    my $doc_root = '/home/mburns/projects/App_magic_tcg/';  # hard code for now TODO have the server find this
    my $card_name = $self->param('name');

    if ( $card_name ) {
        ##### check db first. if not there then got to magiccards.info

        $info = $self->get_db_info( $card_name );
        my $card_img = MagicScrape::Info::card_img_name( $card_name );

        if ( $info->{name} ) {
            $info->{real_name} = $info->{name};
            $info->{image_path} = "card_images/$card_img.jpeg";
        }
        else {
            $info = MagicScrape::Info::get_general_info( $card_name, $doc_root );
        }
    }

    $self->stash(
        card_id        => $info->{card_id},
        name           => $info->{real_name},
        description    => $info->{description},
        flavor_text    => $info->{flavor_text},
        image_path     => $info->{image_path},
        type           => $info->{type},
        subtype        => $info->{subtype},
        generic_mana   => $info->{generic_mana},
        specific_mana  => $info->{specific_mana},
        converted_mana => $info->{converted_mana},
        power          => $info->{power},
        toughness      => $info->{toughness},
        edition        => $info->{edition},
        rarity         => $info->{rarity},
        quantity       => $info->{quantity} || 0,
        notes          => $info->{notes},
    );

    $self->render();
}

sub save_data {
    my $self = shift;
    my $data = shift;

    my $sth;

    if ( $data->{card_id} ) {
        $sth = $DBH->prepare(q{
            UPDATE card
            SET
                name = ?,
                description = ?,
                flavor_text = ?,
                type = ?,
                subtype = ?,
                power = ?,
                toughness = ?,
                generic_mana = ?,
                specific_mana = ?,
                converted_mana = ?,
                edition = ?,
                rarity = ?,
                quantity = ?,
                notes = ?
            WHERE
                card_id = ?
        });
    }
    else {
        $sth = $DBH->prepare(q{
            INSERT INTO card
            (
                name,
                description,
                flavor_text,
                type,
                subtype,
                power,
                toughness,
                generic_mana,
                specific_mana,
                converted_mana,
                edition,
                rarity,
                quantity,
                notes
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
                ?,
                ?
            )
        });
    }

    my @bound = (
        $data->{name} || '',
        $data->{description} || '',
        $data->{flavor_text} || '',
        $data->{type} || '',
        $data->{subtype} || '',
        $data->{power} || '',
        $data->{toughness} || '',
        $data->{generic_mana} || '',
        $data->{specific_mana} || '',
        $data->{converted_mana} || '',
        $data->{edition} || '',
        $data->{rarity} || '',
        $data->{quantity} || '',
        $data->{notes} || '',
    );

    push @bound, $data->{card_id} if $data->{card_id};

    $sth->execute( @bound );

    if ( $sth->err ) {
        return $sth->errstr;
    }
    else {
        return 1;
    }
}

sub get_db_info {
    my (
        $self,
        $name,
    ) = @_;

    $name = lc($name);
    my $sth = $DBH->prepare(q{ SELECT * FROM card WHERE LOWER(name) = ? });
    $sth->execute( $name );
    my $card = $sth->fetchrow_hashref();
    return $card;

}

sub clear_db {
    my $self = shift;

    return $DBH->do(q{ DELETE FROM card });
}

1;
