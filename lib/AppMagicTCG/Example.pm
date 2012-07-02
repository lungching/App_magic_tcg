package AppMagicTCG::Example;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub welcome {
  my $self = shift;

    my $time = localtime;

  # Render template "example/welcome.html.ep" with message
  $self->render(
    message => "Welcome to the Mojolicious real-time web framework! The current time is $time");
}

1;
