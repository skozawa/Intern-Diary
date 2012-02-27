package Diary::Engine::Comment;
use strict;
use warnings;
use Diary::Engine -Base;

sub default : Public {
    my ($self, $r) = @_;
    
    $r->res->redirect('/');
}

## コメントの追加
sub add : Public {
    my ($self, $r) = @_;
    
    $r->follow_method;
}

sub _add_get {
}

sub _add_post {
    my ($self, $r) = @_;
    
    $r->req->form(
        entry_id => [ 'UINT' ],
        content => [ 'NOT_BLANK' ],
    );
    
    if (not $r->req->form->has_error) {
        my $entry_id = $r->req->param('entry_id');
        my $content = $r->req->param('content');
        
        my $comment = $r->user->add_comment(
            entry_id => $entry_id,
            content => $content,
        );
        
        $r->res->redirect("/diary?id=$entry_id");
    }
}

## コメントの削除
sub delete : Public {
    my ($self, $r) = @_;
    
    $r->follow_method;
}

sub _delete_get {
}

sub _delete_post {
    my ($self, $r) = @_;
    
    $r->req->form(
        entry_id => [ 'UINT' ],
        cid => [ 'UINT' ],
    );
    
    if (not $r->req->form->has_error) {
        my $entry_id = $r->req->param('entry_id');
        my $cid = $r->req->param('cid');
        
        my $comment = $r->user->delete_comment( comment_id => $cid );
        
        $r->res->redirect("/diary?id=$entry_id");
    }
}


1;
