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
	
	my $page = $args{page} || 1;
	my $limit = $args{limit} || 3;
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
    
    return moco("Entry")->create(
        title => $args{title},
        body => $args{body},
        user_id => $self->id,
    );
}


sub delete_diary {
	my ($self, %args) = @_;
	
	my $diary = $self->diary($args{diary_id});
	
	
	$diary->delete;
	return $diary;
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
	
	my $page = $args{page} || 1;
	my $limit = $args{limit} || 3;
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


