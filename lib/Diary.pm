package Diary;
use strict;
use warnings;
use base qw/Ridge/;
use Diary::MoCo;
use Ridge::Exceptions;

__PACKAGE__->configure;

sub user {
    my ($self) = @_;
    
    if (my $name = ($self->req->env->{'hatena.user'} || $self->req->env->{'twitter.user'})) {
        my $user = moco('User')->find(name => $name) || moco('User')->create(name => $name);
    } else {
        
    }
}



__PACKAGE__->add_trigger(
    before_dispatch => sub {
        my ($self) = @_;
        return if ($self->req->uri->path eq '/index.login');
        
        if (not ($self->req->env->{'hatena.user'} || $self->req->env->{'twitter.user'})) {
            $self->res->redirect('/index.login');
            Ridge::Exception::RequestError->throw(code => 302);
            return;
        }
    }
);

1;
