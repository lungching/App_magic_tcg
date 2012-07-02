package AppMagicTCG::Start;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub show {
  my $self = shift;

    my $time = localtime;

  $self->render(
    template => 'start',
    format => 'html',
    handler => 'ep',
    message => "Welcome to the Mojolicious real-time web framework! The current time is $time",
  );
}

1;
