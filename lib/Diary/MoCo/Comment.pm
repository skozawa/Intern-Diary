package Diary::MoCo::Comment;

use strict;
use warnings;

use base 'Diary::MoCo';
use Diary::MoCo;

__PACKAGE__->table('comment');

__PACKAGE__->utf8_columns('content');



sub as_string {
	my $self = shift;
	
	return sprintf "%d: %d\t%s\n%s", (
        $self->id,
        $self->diary_id,
        $self->created_on->ymd,
        $self->content,
    );
}


1;
