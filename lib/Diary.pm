package Diary;
use strict;
use warnings;
use base qw/Ridge/;
use Diary::MoCo;

__PACKAGE__->configure;

sub user {
    my ($self) = @_;
    
    if (my $name = ($self->req->env->{'hatena.user'} || $self->req->env->{'twitter.user'})) {
        my $user = moco('User')->find(name => $name) || moco('User')->create(name => $name);
    } else {

    }
}

1;
