package Diary::MoCo::Category;

use strict;
use warnings;

use base 'Diary::MoCo';
use Diary::MoCo;
use Carp qw(croak);

__PACKAGE__->table('category');

__PACKAGE__->utf8_columns(qw(name));

## カテゴリ一覧の取得
sub categories {
    my ($self, %args) = @_;
    
    my $page = $args{page} || 1;
    my $limit = $args{limit} || 5;
    my $offset = ($page - 1) * $limit;
    
    return $self->search(
         limit => $limit,
         offset => $offset,
         order => 'id ASC',
    );
}

sub entries {
    my ($self, %args) = @_;
    
    my $page = $args{page} || 1;
    my $limit = $args{limit} || 5;
    my $offset = ( $page - 1 ) * $limit;
    
    my @entry_ids;
    for (moco('RelEntryCategory')->search( where => { category_id => $self->id } )) {
        push @entry_ids, $_->entry_id;
    }
    return [] if (!@entry_ids);
    
    return moco('Entry')->search(
        where => {
            id => { -in => [@entry_ids] },
        },
        limit => $limit,
        offset => $offset,
        order => 'created_on DESC',
    );
}

sub entry_size {
    my $self = shift;
    
    my @entry_ids;
    for (moco('RelEntryCategory')->search( where => { category_id => $self->id } )) {
        push @entry_ids, $_->entry_id;
    }
    return 0 if (!@entry_ids);
    
    return $self->count( id => { -in => [@entry_ids] } );
}


sub as_string {
    my ($self) = shift;
    
    return sprintf "%d: %s\t%s", (
        $self->id,
        $self->name,
        $self->created_on->ymd,
    );
}

1;

