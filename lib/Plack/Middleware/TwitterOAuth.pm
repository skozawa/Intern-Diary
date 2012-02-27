package Plack::Middleware::TwitterOAuth;
use strict;
use warnings;

use parent 'Plack::Middleware';
use Plack::Util::Accessor qw( consumer_key consumer_secret consumer login_path );
use Plack::Request;
use Plack::Session;

use OAuth::Lite::Consumer;
use JSON::XS;

use Data::Dumper 'Dumper';

sub prepare_app {
    my ($self) = @_;
    die 'require consumer_key and consumer_secret'
        unless $self->consumer_key and $self->consumer_secret;

    $self->consumer(OAuth::Lite::Consumer->new(
        consumer_key       => $self->consumer_key,
        consumer_secret    => $self->consumer_secret,
        site               => q{https://api.twitter.com},
        request_token_path => q{/oauth/request_token},
        access_token_path  => q{/oauth/access_token},
        authorize_path     => q{https://api.twitter.com/oauth/authorize},
        ($self->{ua} ? (ua => $self->{ua}) : ()),
    ));
}

sub call {
    my ($self, $env) = @_;
    my $session = Plack::Session->new($env);
    
    my $handlers = {
        $self->login_path => sub {
            my $req = Plack::Request->new($env);
            my $res = $req->new_response(200);
            my $consumer = $self->consumer;
            my $verifier = $req->param('oauth_verifier');
            
            if ( $verifier ) {
                my $access_token = $consumer->get_access_token(
                    token    => $session->get('oauth_token'),
                    verifier => $verifier,
                ) or die $consumer->errstr;
                $session->remove('oauth_token');
                
                {
                    my $res = $consumer->request(
                        method => 'GET',
                        url    => qq{http://api.twitter.com/1/account/verify_credentials.json},
                        token  => $access_token,
                    );
                    $res->is_success or die;
                    $session->set('oauth_user_info', decode_json($res->decoded_content || $res->content));
                }
                $res->redirect( $session->get('oauth_location') || '/' );
                $session->remove('oauth_location');
            } else {
                my $request_token = $self->consumer->get_request_token(
                    callback_url => [ split /\?/, $req->uri, 2]->[0],
                ) or die $consumer->errstr;
                
                $session->set(oauth_token => $request_token);
                $session->set(oauth_location => $req->param('location'));
                $res->redirect($consumer->url_to_authorize(token => $request_token));
            }
            return $res->finalize;
        },
    };
    
    $env->{'twitter.user'} = ($session->get('oauth_user_info') || {})->{screen_name};
    return ($handlers->{$env->{PATH_INFO}} || $self->app)->($env);
}

1;

__END__

=head1 SYNOPSIS

  use Plack::Builder;

  my $app = sub {
      my $env = shift;
      my $session = $env->{'psgix.session'};
      return [
          200,
          [ 'Content-Type' => 'text/html' ],
          [
              "<html><head><title>Hello</title><body>",
              $env->{'hatena.user'}
                  ? ('Hello, id:' , $env->{'hatena.user'}, ' !')
                  : "<a href='/login?location=/'>Login</a>"
          ],
      ];
  };

  builder {
      enable 'Session';
      enable 'Plack::Middleware::TwitterOAuth',
           consumer_key       => 'F3khxwmfD6xW9C8JAGA',
           consumer_secret    => 'I2ma3elmHLLdkMGMx0JPKslHTowLh5R3xJfzenIKmg',
           login_path         => '/login_twitter';
           # ua                => LWP::UserAgent->new(...);
      $app;
  };

=cut

