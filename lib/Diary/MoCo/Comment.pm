package Diary::MoCo::Comment;

use strict;
use warnings;

use base 'Diary::MoCo';
use Diary::MoCo;

__PACKAGE__->table('comment');

__PACKAGE__->utf8_columns('content');


sub user {
    my $self = shift;
    
    return moco('User')->find(id => $self->user_id);
}

sub as_string {
    my $self = shift;
    
    return sprintf "%d: %d\t%s\n%s", (
        $self->id,
        $self->entry_id,
        $self->created_on->ymd,
        $self->content,
    );
}


1;
