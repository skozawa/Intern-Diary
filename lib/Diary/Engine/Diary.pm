package Diary::Engine::Diary;
use strict;
use warnings;
use Diary::Engine -Base;

use Diary::MoCo;

sub default : Public {
    my ($self, $r) = @_;
    
    my $id = $r->req->param('id');
    my $entry = moco('Entry')->find(id => $id);
    my $categories = moco('Category')->get_category_by_entry(entry_id => $entry->id);
    my $comments = $entry->comments();
    
    $r->stash->param(
        entry => $entry,
        categories => $categories,
        comments => $comments,
    );
}


sub add : Public {
    my ($self, $r) = @_;
    
    my $id = $r->req->param('id');
    my $entry = $id ? moco('Entry')->find(id => $id) : undef;
    my $categories = $entry ? moco('Category')->get_category_by_entry(entry_id => $entry->id) : undef;
    
    $r->stash->param(
        entry => $entry,
        categories => $categories,
    );
    
    #$r->follow_method;
}

sub _add_get {
}

sub _add_post {
    my ($self, $r) = @_;
    
    my $title = $r->req->param('title');
    my $category = $r->req->param('category');
    my $body = $r->req->param('body');
    
    my $entry = $r->user->add_entry (
        title => $title,
        body => $body,
    );
    $r->user->add_category(
        category => $category,
        entry_id => $entry->id,
    );
    
    $r->res->redirect('/');
}


sub delete : Public {
    my ($self, $r) = @_;
    
    my $id = $r->req->param('id');
    my $entry = $id ? moco('Entry')->find(id => $id) : undef;
    my $categories = $entry ? moco('Category')->get_category_by_entry(entry_id => $entry->id) : undef;
    
    $r->stash->param(
        entry => $entry,
        categories => $categories,
    );
    
    #$r->follow_method;
}

sub _delete_get {
}

sub _delete_post {
    my ($self, $r) = @_;
    
    $r->user->delete_entry(entry_id => $r->stash->param('entry')->id);
    
    $r->res->redirect('/');
}


sub edit : Public {
    my ($self, $r) = @_;
    
    my $id = $r->req->param('id');
    my $entry = $id ? moco('Entry')->find(id => $id) : undef;
    my $categories = $entry ? moco('Category')->get_category_by_entry(entry_id => $entry->id) : undef;
    my @category = map {$_->name} @$categories;
    
    $r->stash->param(
        entry => $entry,
        category => join(",",@category),
    );
    
    #$r->follow_method;
}

sub _edit_get {
}

sub _edit_post {
    my ($self, $r) = @_;
    
    my $id = $r->req->param('id');
    my $title = $r->req->param('title');
    my $category = $r->req->param('category');
    my $body = $r->req->param('body');
    
    my $entry = $r->user->edit_entry (
        entry_id => $id,
        title => $title,
        body => $body,
        category => $category
    );
    
    $r->res->redirect('/');
}


sub search : Public {
    my ($self, $r) = @_;
    
    my $user = moco("User")->find(name => 'kozawa');
    my $query = $r->req->param('query');
    #my $entries = $r->user->search_entry($query);
    my $entries = $user->search_entry(query => $query);
    my $categories;
    for my $entry (@$entries) {
        $categories->{$entry->id} = moco('Category')->get_category_by_entry( entry_id => $entry->id );
    }
   
    $r->stash->param(
        entries => $entries,
        categories => $categories,
    );
    
    #$r->follow_method;
}


1;
