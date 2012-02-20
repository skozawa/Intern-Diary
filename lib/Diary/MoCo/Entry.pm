package Diary::MoCo::Entry;

use strict;
use warnings;

use base 'Diary::MoCo';
use Diary::MoCo;
use Carp qw(croak);

__PACKAGE__->table('entry');

__PACKAGE__->utf8_columns(qw(title body));


## カテゴリIDを用いた日記の取得
sub get_entry_by_category {
    my ($self, %args) = @_;
    
    defined $args{cid} && $args{cid} ne "" or croak "Required: category_id";
    
    my $page = $args{page} || 1;
    my $limit = $args{limit} || 5;
    my $offset = ($page - 1) * $limit;
    
    return $self->search(
        where => {
            category_ids => [ {-like => $args{cid}},
                              {-like => $args{cid}.',%'},
                              {-like => '%,'.$args{cid}},
                              {-like => '%,'.$args{cid}.',%'}],
        },
        limit => $limit,
        offset => $offset,
        order => 'created_on DESC',
    );
}

sub comments {
    my ($self, %args) = @_;
    
    my $page = $args{page} || 1;
    my $limit = $args{limit} || 5;
    my $offset = ($page - 1) * $limit;
    
    return moco("Comment")->search(
        where => { diary_id => $self->id },
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
