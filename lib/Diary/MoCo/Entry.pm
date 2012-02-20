package Diary::MoCo::Entry;

use strict;
use warnings;

use base 'Diary::MoCo';
use Diary::MoCo;

__PACKAGE__->table('entry');

__PACKAGE__->utf8_columns(qw(title body));



sub get_entry_by_category {
	my ($self, %args) = @_;
	
	my $page = $args{page};
	my $limit = $args{limit};
	my $offset = ($page - 1) * $limit;
	
	return $self->search(
         where => {
             category_ids => [ {-like => $args{cid}.',%'},
						       {-like => '%,'.$args{cid}},
							   {-like => '%,'.$args{cid}.',%'}],
         },
         limit => $limit,
         offset => $offset,
		 order => 'created_on DESC',
    );
}


sub as_string {
	my $self = shift;
	
	return sprintf "%d: %s\t%s\t%s(%s)\n%s", (
        $self->id,
        $self->title,
        $self->category_ids,
        $self->created_on->ymd,
        $self->updated_on->ymd,
        $self->body,
    );
}

1;
