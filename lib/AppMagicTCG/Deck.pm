package AppMagicTCG::Deck;
use Mojo::Base 'Mojolicious::Controller';

use DBD::SQLite;
use Data::Printer;
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
        my $found_deck = search_deck_name($self->param('deck_name'));

        if ( $found_deck ) {
            $self->show_deck();
        }
        else {
            $self->stash('error' => 'Could not find deck ' . $self->param('deck_name') . '.');
        }
    }

}

sub search_deck_name {
    my $name = shift;

    my @found = $DBH->selectrow_array("SELECT COUNT(*) FROM deck WHERE name = ?", undef, $name);

    return $found[0];
}

sub new_deck {
    my $self = shift;

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

    $self->stash(
        deck_id      => $info->{deck_id},
        deck_name    => $info->{name},
        notes        => $info->{notes},
        image_path   => '',
        saved_result => '',
    );

    $self->render('deck/detail');
}

sub get_deck_info {
    my $name = shift;

    my $info = $DBH->selectrow_hashref("SELECT * FROM deck WHERE name = ?", undef, $name);

    return $info;
}

1;
