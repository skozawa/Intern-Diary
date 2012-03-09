package Diary::Engine::API::Index;
use strict;
use warnings;
use Diary::Engine -Base;
use JSON;
use Diary::MoCo;

sub default : Public {
    my ($self, $r) = @_;
    #$r->res->content('Diary');
    
    $r->req->form(
        page => ['NOT_BLANK','UINT'],
    );
    
    if (not $r->req->form->has_error) {
        my $page = $r->req->param('page');
        my $limit = 3;
        
        my $entries = $r->user->entries(page => $page);
        my $entry_size = $r->user->entry_size;
        my $has_pre = $page * $limit < $entry_size ? 1 : 0;
        
        $r->stash->param(
            entries => $entries,
            page => $page,
            has_pre => $has_pre,
        );
    }
}


sub edit : Public {
    my ($self, $r) = @_;
    
    my $id = $r->req->param('id');
    my $entry = $id ? moco('Entry')->find( id => $id, user_id => $r->user->id ) : undef;
    
    if ( !$entry ) {
        $r->res->redirect('/');
        return;
    }
    
    $r->follow_method;
}

sub _edit_get {
}

sub _edit_post {
    my ($self, $r) = @_;
    
    $r->req->form(
        id => ['NOT_BLANK', 'UINT'],
        title => ['NOT_BLANK'],
        body => ['NOT_BLANK'],
    );
    
    if (not $r->req->form->has_error) {
        my $id = $r->req->param('id');
        my $title = $r->req->param('title');
        my $category = $r->req->param('category');
        my $body = $r->req->param('body');
        
        my $entry = $r->user->edit_entry (
            entry_id => $id,
            title => $title,
            body => $body,
            category => $category,
        );
        
        $r->stash->param(
            entry => $entry,
        );
    }
}

1;
