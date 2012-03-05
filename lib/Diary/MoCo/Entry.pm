package Diary::MoCo::Entry;

use strict;
use warnings;

use base 'Diary::MoCo';
use Diary::MoCo;
use Carp qw(croak);

__PACKAGE__->table('entry');

__PACKAGE__->utf8_columns(qw(title body));


sub user {
    my $self = shift;
    
    return moco('User')->find(id => $self->user_id);
}

sub categories {
    my $self = shift;
    
    my @category_ids = map { $_->category_id }
        moco('RelEntryCategory')->search( where => { entry_id => $self->id } );
    
    return [] if (!@category_ids);
    
    return moco('Category')->search( where => { id => { -in => [@category_ids] } } );
}


## エントリに対するコメントを取得
sub comments {
    my ($self, %args) = @_;
    
    #my $page = $args{page} || 1;
    #my $limit = $args{limit} || 5;
    #my $offset = ($page - 1) * $limit;
    
    return moco("Comment")->search(
        where => { entry_id => $self->id },
        #limit => $limit,
        #offset => $offset,
        order => 'created_on DESC',
    );
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
