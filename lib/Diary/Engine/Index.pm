package Diary::Engine::Index;
use strict;
use warnings;
use Diary::Engine -Base;

use Diary::MoCo;
use Plack::Session;

sub default : Public {
    my ($self, $r) = @_;
    
    my $entries = $r->user->entries;
    my $categories;
    for my $entry (@$entries) {
        $categories->{$entry->id} = moco('Category')->get_category_by_entry( entry_id => $entry->id );
    }

    $r->stash->param(
        entries => $entries,
        categories => $categories,
    );
}

sub login : Public {
    my ($self, $r) = @_;
    
    if ( my $user = $r->user ) {
        $r->res->redirect("/");
        return;
    }
}

sub logout : Public {
    my ($self, $r) = @_;
    
    my $session = Plack::Session->new($r->req->env);
    my $arg = { session_id => $session->id };
    $session->expire;
    
    my $res = $r->req->new_response(200);
    $res->content_type('text/html');
    $res->finalize;
    
    $r->res->redirect('/index.login');
}

sub mypage : Public {
    my ($self, $r) = @_;
    
    my $entries = $r->user->entries;
    
    $r->stash->param(
        entries => $entries,
    );
}


1;
