package AppMagicTCG;
use Mojo::Base 'Mojolicious';

use AppMagicTCG::Card;
use AppMagicTCG::Deck;
use Data::Printer;

has conf_file => 'conf/db_conf.json';

# This method will run once at server start
sub startup {
    my $self = shift;
    my $config = $self->plugin( 'JSONConfig' => { file => $self->conf_file } );
# p($config->{db}{dsn});

  AppMagicTCG::Card->init( $config->{db} );
  AppMagicTCG::Deck->init( $config->{db} );

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('card#index', deck_list => AppMagicTCG::Deck::get_deck_list(), )->name("start");
  $r->route('/card')->via('GET', 'POST')->to('card#info')->name("card_info");
  $r->route('/deck')->via('GET', 'POST')->to('deck#admin', deck_list => AppMagicTCG::Deck::get_deck_list(), )->name("deck_admin");
}

1;
