package Diary::MoCo::User;

use strict;
use warnings;

use base 'Diary::MoCo';
use Diary::MoCo;
use Carp qw(croak);

use Diary::MoCo::Entry;


__PACKAGE__->table('user');


sub diary {
	my ($self, $diary_id) = @_;
	
	my $diary = moco("Entry")->find(id=>$diary_id);
	defined $diary or croak q(Not found diary);
    $diary->user_id == $self->id or croak q(Not your diary);
	
	return $diary;
}


sub diaries {
    my ($self, %args) = @_;
	
	my $page = $args{page};
	my $limit = $args{limit};
	my $offset = ($page - 1) * $limit;
	
	return moco("Entry")->search(
         where => { user_id => $self->id, },
         limit => $limit,
         offset => $offset,
		 order => 'created_on DESC',
    );
}


sub add_diary {
    my ($self, %args) = @_;
    
	my $categories = $self->add_category($args{category});
	
    return moco("Entry")->create(
        title => $args{title},
        body => $args{body},
        category_ids => join(",",@$categories),
        user_id => $self->id,
    );
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

sub delete_diary {
	my ($self, %args) = @_;
	
	my $diary = $self->diary($args{diary_id});
	
	
	$diary->delete;
	return $diary;
}

sub search_diary {
	my ($self, %args) = @_;
	
	my $page = $args{page};
	my $limit = $args{limit};
	my $offset = ($page - 1) * $limit;
	
	my @where = (
	    { body => {-like => '%'.$args{query}.'%'}},
		{ title => {-like => '%'.$args{query}.'%'}},
    );
	
	return moco("Entry")->search(
         #where => {
         #    body => {-like => '%'.$args{query}.'%'},
         #    title => {-like => '%'.$args{query}.'%'},
         #},
         where => ['body like :query or title like :query', query => '%'.$args{query}.'%'],
         limit => $limit,
         offset => $offset,
		 order => 'created_on DESC',
    );
	
}


sub comment {
	my ($self, $comment_id) = @_;
	
	my $comment = moco("Comment")->find(id=>$comment_id);
	defined $comment or croak q(Not found comment);
    $comment->user_id == $self->id or croak q(Not your comment);
	
	return $comment;
}

sub comments {
	my ($self, %args) = @_;
	
	my $page = $args{page};
	my $limit = $args{limit};
	my $offset = ($page - 1) * $limit;
	
	return moco("Comment")->search(
         where => { user_id => $self->id, },
         limit => $limit,
         offset => $offset,
		 order => 'created_on DESC',
    );
}

sub add_comment {
	my ($self, %args) = @_;
	
	return moco("Comment")->create(
        user_id => $self->id,
        diary_id => $args{diary_id},
        content => $args{content},
    );
}

sub delete_comment {
	my ($self, %args) = @_;
	
	my $comment = $self->comment($args{comment_id});
	
	$comment->delete;
	return $comment;
}



1;


