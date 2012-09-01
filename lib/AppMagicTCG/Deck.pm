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
        my $deck = get_deck_name($self->param('deck_name'));

        if ( $deck ) {
            $self->show_deck();
        }
        else {
            $self->stash('error' => 'Could not find deck ' . $self->param('deck_name') . '.');
        }
    }

}

sub get_deck_name {
    my $name = shift;

    return;
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
}

1;
