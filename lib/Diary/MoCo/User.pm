package Diary::MoCo::User;

use strict;
use warnings;

use base 'Diary::MoCo';
use Diary::MoCo;
use Carp qw(croak);


__PACKAGE__->table('user');

## 日記一覧の取得
sub entries {
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

## ユーザの書いたエントリ数
sub entry_size {
    my ($self) = @_;
    
    return moco('Entry')->count(user_id => $self->id);
}

## 日記の追加
sub add_entry {
    my ($self, %args) = @_;
    
    ## 入力確認
    defined $args{title} && $args{title} ne "" or croak "Required: title";
    defined $args{body} && $args{body} ne "" or croak "Required: body";
    
    return moco("Entry")->create(
        title => $args{title},
        body => $args{body},
        user_id => $self->id,
    );
}

## カテゴリ追加
sub add_category {
    my ($self, %args) = @_;
    
    defined $args{entry_id} && $args{entry_id} ne "" or croak "Required: entry_id";
    return if (!defined $args{category} || $args{category} eq "");

    foreach my $c (split(/,/,$args{category})) {
        my $category;
        ## 既に存在するカテゴリかどうか
        if ($category = moco("Category")->find(name => $c)) {
        } else {
            ## カテゴリ追加
            $category = moco("Category")->create(name => $c);
        }
        moco("Rel_entry_category")->create(
            entry_id => $args{entry_id},
            category_id => $category->id,
        );
    }
}

## 日記の削除
sub delete_entry {
    my ($self, %args) = @_;
    
    defined $args{entry_id} && $args{entry_id} ne '' or croak "Reequired: entry_id";
    
    my $entry = moco('Entry')->find(id => $args{entry_id}, user_id => $self->id);
    ## ユーザ自身の日記か
    $entry->user_id == $self->id or croak q(Not your entry);
    
    $entry->delete;
    
    ## カテゴリの削除
    foreach my $relation ( moco("Rel_entry_category")->search( where => { entry_id => $entry->id } )) {
        $relation->delete;
    }
    ## コメントの削除
    foreach my $comment ( moco("Comment")->search( where => { entry_id => $entry->id } )) {
        $comment->delete;
    }
    
    return $entry;
}

## 日記の編集
sub edit_entry {
    my ($self, %args) = @_;
    
    defined $args{entry_id} && $args{entry_id} ne "" or croak "Required: entry_id";
    defined $args{category} or croak "Required: category";
    defined $args{title} && $args{title} ne "" or croak "Required: title";
    defined $args{body} && $args{body} ne "" or croak "Required: body";
    
    my $entry = moco('Entry')->find(id => $args{entry_id}, user_id => $self->id);
    ## ユーザ自身の日記か
    $entry->user_id == $self->id or croak q(Not your entry);
    
    $entry->title($args{title});
    $entry->body($args{body});
    
    return if( $args{category} eq "" );
    
    ## カテゴリとエントリの関係を削除
    foreach my $relation ( moco("Rel_entry_category")->search( where => { entry_id => $entry->id } )) {
        $relation->delete;
    }
    $self->add_category( entry_id => $entry->id, category => $args{category} );
    
    return $entry;
}

## 日記の検索
sub search_entry {
    my ($self, %args) = @_;
    
    defined $args{query} && $args{query} ne "" or croak "Required: query";
    
    my $page = $args{page} || 1;
    my $limit = $args{limit} || 3;
    my $offset = ($page - 1) * $limit;
    
    ## タイトルか本文にキーワードを含む日記を検索
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

sub search_result_size {
    my ($self, $query) = @_;
    
    return moco('Entry')->count(['body like :query or title like :query', query => '%'.$query.'%']);
}

## comment_idのコメントを取得
sub comment {
    my ($self, $comment_id) = @_;
    
    my $comment = moco("Comment")->find(id=>$comment_id);
    defined $comment or croak q(Not found comment);
    
    return $comment;
}

## コメント一覧の取得
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

## コメントの追加
sub add_comment {
    my ($self, %args) = @_;
    
    defined $args{entry_id} && $args{entry_id} ne "" or croak "Required: entry_id";
    moco("Entry")->has_row(id => $args{entry_id}) or croak "Not found entry\n";
    defined $args{content} && $args{content} ne "" or croak "Required: entry_id";
    
    return moco("Comment")->create(
        user_id => $self->id,
        entry_id => $args{entry_id},
        content => $args{content},
    );
}

## コメントの削除
sub delete_comment {
    my ($self, %args) = @_;
    
    defined $args{comment_id} && $args{comment_id} ne "" or croak "Required: comment_id";
    
    my $comment = $self->comment($args{comment_id});
    ## ユーザ自身のコメントかどうか
    $comment->user_id == $self->id or croak q(Not your comment);
    
    $comment->delete;
    return $comment;
}



1;


