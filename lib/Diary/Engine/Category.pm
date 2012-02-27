package Diary::Engine::Category;
use strict;
use warnings;
use Diary::Engine -Base;

use Diary::MoCo;

sub default : Public {
    my ($self, $r) = @_;
    
    my $id = $r->req->param('id');
    if (!defined $id || $id eq "") {
        $r->res->redirect('/category.all');
        return;
    }
    
    my $category = moco('Category')->find(id => $id);
    my $entries = moco('Entry')->get_entry_by_category( cid => $id );
    
    $r->stash->param( 
        category => $category,
        entries => $entries,
    );
}

sub all : Public {
    my ($self, $r) = @_;
    
    my $categories = moco('Category')->categories;
    my $entries;
    for my $category (@$categories) {
        $entries->{$category->id} = moco('Entry')->get_entry_by_category( cid => $category->id );
    }
    
    $r->stash->param(
        categories => $categories,
        entries => $entries,
    );
}


1;
