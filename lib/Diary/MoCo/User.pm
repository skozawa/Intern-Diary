package Diary::MoCo::User;

use strict;
use warnings;

use base 'Diary::MoCo';
use Diary::MoCo;
use Carp qw(croak);

use Diary::MoCo::Entry;

__PACKAGE__->table('user');


sub add_diary {
    my ($self, %args) = @_;
    
    defined $args{body} or croak q(add_diary: parameter 'body' required);
    
    return moco("Entry")->create(
        title => $args{title},
        body => $args{body},
        user_id => $self->id,
    );
}

sub delete_diary {
	my ($self, %args) = @_;
	
	my $diary = moco("Entry")->find(id => $args{diary_id});
	defined $diary or croak q(Not found diary);
    $diary->user_id == $self->id or croak q(Not your diary);
	
	$diary->delete;
	return $diary;
}

sub diaries {
    my ($self, %opts) = @_;
	
	my $page = $opts{page} || 1;
	my $limit = $opts{limit} || 3;
	my $offset = ($page - 1) * $limit;
	
	return moco("Entry")->search(
         where => { user_id => $self->id, },
         limit => $limit,
         offset => $offset,
		 order => 'created_on DESC',
    );
}


1;


