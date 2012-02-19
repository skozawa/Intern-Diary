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
	
	return if(!defined $args{category} || $args{category} eq "");
	my $categories = $self->add_category($args{category});
	$self->category_ids(join(",",@$categories));
}

sub add_category {
	my ($self, $category) = @_;
	
	my $categories = [];
	foreach my $c (split(/,/,$category)) {
		if (moco("Category")->has_row(name => $c)) {
			push @$categories, moco("Category")->find(name => $c)->id;
		} else {
			my $category = moco("Category")->create(name => $c);
			push @$categories, $category->id;
		}
	}
	
	return $categories;
}

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
