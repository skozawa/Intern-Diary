package Diary::Engine::API::Index;
use strict;
use warnings;
use Diary::Engine -Base;
use JSON;

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

1;
