package Diary::MoCo::Comment;

use strict;
use warnings;

use base 'Diary::MoCo';

__PACKAGE__->table('comment');

__PACKAGE__->utf8_columns('content');


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
