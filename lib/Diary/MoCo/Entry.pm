package Diary::MoCo::Entry;

use strict;
use warnings;

use base 'Diary::MoCo';
use Diary::MoCo;

__PACKAGE__->table('entry');

__PACKAGE__->utf8_columns(qw(title body));


sub update_entry {
	my ($self, %args) = @_;
	
	$self->title($args{title});
	$self->body($args{body});
}


sub as_string {
	my $self = shift;
	
	return sprintf "%d: %s\t%s(%s)\n%s", (
        $self->id,
        $self->title,
        $self->created_on->ymd,
        $self->updated_on->ymd,
        $self->body,
    );
}

1;
