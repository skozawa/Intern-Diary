package Diary::Engine::Index;
use strict;
use warnings;
use Diary::Engine -Base;

use Diary::MoCo;

sub default : Public {
    my ($self, $r) = @_;
    
    my $user = moco("User")->find(name => 'kozawa');
    
    my $entries = $user->entries;
    #my $categories = moco('Category')->get_category_by_entries($entries);
    my $categories;
    for my $entry (@$entries) {
        $categories->{$entry->id} = moco('Category')->get_category_by_entry( entry_id => $entry->id );
    }

    $r->stash->param( 
        entries => $entries,
        categories => $categories,
    );
}

1;
