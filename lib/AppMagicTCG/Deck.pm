package AppMagicTCG::Deck;
use Mojo::Base 'Mojolicious::Controller';

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

# This action will render a template
sub admin {
    my $self = shift;

    my $info;

    $self->stash( saved_result => undef );

    if ( $self->param('new') ) {
    }
    elsif ( $self->param('save') ) {
        my $saved_result;
        $self->stash( saved_result => $saved_result );
    }

    my $doc_root = '/home/mburns/projects/App_magic_tcg/';  # hard code for now TODO have the server find this
    my $card_name = $self->param('name');


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


1;
