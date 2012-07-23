package AppMagicTCG;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
    my $self = shift;

  # Documentation browser under "/perldoc"
    $self->plugin('PODRenderer');

  # Router
    my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome')->name("start");
  $r->route('/card')->via('GET', 'POST')->to('card#info')->name("card_info");

}

1;
