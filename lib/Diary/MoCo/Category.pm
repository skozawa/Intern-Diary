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

## entry_idでカテゴリを検索
sub get_category_by_entry {
    my ($self, %args) = @_;
    
    defined $args{entry_id} && $args{entry_id} ne "" or croak "Required: entry_id";
    
    my @category_ids = map { $_->category_id }
        moco('Rel_entry_category')->search( where => { entry_id => $args{entry_id} } );

    return if(!@category_ids);
    
    return $self->search( where => { id => { -in => [@category_ids] } } );
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

