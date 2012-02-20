package Diary::MoCo::User;

use strict;
use warnings;

use base 'Diary::MoCo';
use Diary::MoCo;
use Carp qw(croak);


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
    my $limit = $args{limit} || 5;
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
    
    defined $args{category} or croak "Required: category";
    defined $args{title} && $args{title} ne "" or croak "Required: title";
    defined $args{body} && $args{body} ne "" or croak "Required: body";
    
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
    $categories = [sort @$categories];
    
    return $categories;
}

sub delete_diary {
    my ($self, %args) = @_;
    
    defined $args{diary_id} && $args{diary_id} ne '' or croak "Reequired: diary_id";
    
    my $diary = $self->diary($args{diary_id});
    
    
    $diary->delete;
    return $diary;
}

sub edit_diary {
    my ($self, %args) = @_;
    
    defined $args{diary_id} && $args{diary_id} ne "" or croak "Required: diary_id";
    defined $args{category} or croak "Required: category";
    defined $args{title} && $args{title} ne "" or croak "Required: title";
    defined $args{body} && $args{body} ne "" or croak "Required: body";
    
    my $entry = $self->diary($args{diary_id});
    
    $entry->title($args{title});
    $entry->body($args{body});
    
    my $categories = $self->add_category($args{category});
    $entry->category_ids(join(",",@$categories));
    
    return $entry;
}

sub search_diary {
    my ($self, %args) = @_;
    
    defined $args{query} && $args{query} ne "" or croak "Required: query";
    
    my $page = $args{page} || 1;
    my $limit = $args{limit} || 5;
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
    
    my $page = $args{page} || 1;
    my $limit = $args{limit} || 5;
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
    
    defined $args{diary_id} && $args{diary_id} ne "" or croak "Required: diary_id";
    moco("Entry")->has_row(id => $args{diary_id}) or croak "Not found diary\n";
    defined $args{content} && $args{content} ne "" or croak "Required: diary_id";
    
    return moco("Comment")->create(
        user_id => $self->id,
        diary_id => $args{diary_id},
        content => $args{content},
    );
}

sub delete_comment {
    my ($self, %args) = @_;
    
    defined $args{comment_id} && $args{comment_id} ne "" or croak "Required: comment_id";
    
    my $comment = $self->comment($args{comment_id});
    
    $comment->delete;
    return $comment;
}



1;


