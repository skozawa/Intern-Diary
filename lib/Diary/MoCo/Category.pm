package Diary::MoCo::Category;

use strict;
use warnings;

use base 'Diary::MoCo';

__PACKAGE__->table('category');

__PACKAGE__->utf8_columns(qw(name));

## カテゴリ一覧の取得
sub categories {
    my ($self, %args) = @_;
    
    my $page = $args{page} || 1;
    my $limit = $args{limit} || 10;
    my $offset = ($page - 1) * $limit;
    
    return $self->search(
         limit => $limit,
         offset => $offset,
         order => 'id ASC',
    );
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

