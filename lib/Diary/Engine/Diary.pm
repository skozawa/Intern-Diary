package Diary::Engine::Diary;
use strict;
use warnings;
use Diary::Engine -Base;

use Diary::MoCo;
use Carp qw(croak);

## エントリ一覧
sub default : Public {
    my ($self, $r) = @_;
    
    $r->req->form(
        id => ['NOT_BLANK','UINT'],
    );
    
    if (not $r->req->form->has_error) {
        my $id = $r->req->param('id');
        my $entry = moco('Entry')->find(id => $id);
        if ( !$entry ) {
            $r->res->redirect('/');
            return;
        }
        my $entry_user = moco('User')->find(id => $entry->user_id);
        my $categories = moco('Category')->get_category_by_entry(entry_id => $entry->id);
        my $comments = $entry->comments();
        my $comment_users = $self->comment_users($comments);
    
        $r->stash->param(
            entry => $entry,
            entry_user => $entry_user,
            categories => $categories,
            comments => $comments,
            comment_users => $comment_users,
        );
    } else {
        $r->res->redirect('/');
    }
}

## エントリの追加
sub add : Public {
    my ($self, $r) = @_;
    
    $r->follow_method;
}

sub _add_get {
}

sub _add_post {
    my ($self, $r) = @_;
    
    $r->req->form(
        title => ['NOT_BLANK'],
        body => ['NOT_BLANK'],
    );
    
    if (not $r->req->form->has_error) {
        my $title = $r->req->param('title');
        my $category = $r->req->param('category');
        my $body = $r->req->param('body');

        ## エントリの追加
        my $entry = $r->user->add_entry (
            title => $title,
            body => $body,
        );
        ## カテゴリの追加
        $r->user->add_category(
            category => $category,
            entry_id => $entry->id,
        );
        
        $r->res->redirect('/');
    }
}

## エントリの削除
sub delete : Public {
    my ($self, $r) = @_;
    
    my $id = $r->req->param('id');
    my $entry = $id ? moco('Entry')->find( id => $id, user_id => $r->user->id ) : undef;
    my $categories = $entry ? moco('Category')->get_category_by_entry(entry_id => $entry->id) : undef;
    
    ## エントリの確認
    if ( !$entry ) {
        $r->res->redirect('/');
        return;
    }
    
    $r->stash->param(
        entry => $entry,
        categories => $categories,
    );
    
    $r->follow_method;
}

sub _delete_get {
}

sub _delete_post {
    my ($self, $r) = @_;
    
    $r->req->form(
        entry_id => ['NOT_BLANK','UINT'],
    );
    
    if (not $r->req->form->has_error) {
        $r->user->delete_entry(entry_id => $r->stash->param('entry')->id);
    }
    
    $r->res->redirect('/');
}

## エントリの編集
sub edit : Public {
    my ($self, $r) = @_;
    
    my $id = $r->req->param('id');
    my $entry = $id ? moco('Entry')->find( id => $id, user_id => $r->user->id ) : undef;
    my $categories = $entry ? moco('Category')->get_category_by_entry( entry_id => $entry->id ) : undef;
    my @category = map {$_->name} @$categories;
    
    ## エントリが存在するか
    if ( !$entry ) {
        $r->res->redirect('/');
        return;
    }
    
    $r->stash->param(
        entry => $entry,
        category => join(",",@category),
    );
    
    $r->follow_method;
}

sub _edit_get {
}

sub _edit_post {
    my ($self, $r) = @_;

    $r->req->form(
        id => ['NOT_BLANK','UINT'],
        title => ['NOT_BLANK'],
        body => ['NOT_BLANK'],
    );
    
    if (not $r->req->form->has_error) {
        my $id = $r->req->param('id');
        my $title = $r->req->param('title');
        my $category = $r->req->param('category');
        my $body = $r->req->param('body');
        
        ## エントリの編集
        my $entry = $r->user->edit_entry (
            entry_id => $id,
            title => $title,
            body => $body,
            category => $category
        );
        $r->res->redirect('/');
    }
}

## エントリの検索
sub search : Public {
    my ($self, $r) = @_;
    
    $r->req->form(
        query => ['NOT_BLANK'],
        page => ['UINT'],
    );
    
    if (not $r->req->form->has_error) {
        my $page = $r->req->param('page') || 1;
        my $limit = 3;
        
        my $query = $r->req->param('query');
        my $entries = $r->user->search_entry( query => $query, page => $page );
        my $categories;
        for my $entry (@$entries) {
            $categories->{$entry->id} = moco('Category')->get_category_by_entry( entry_id => $entry->id );
        }
        my @user_ids = map { $_->user_id } @$entries;
        my $entry_users = $self->entry_users(\@user_ids);
        
        my $result_size = $r->user->search_result_size($query);
        my $has_next = $page * $limit < $result_size ? 1 : 0;
        
        $r->stash->param(
            query => $query,
            entries => $entries,
            categories => $categories,
            entry_users => $entry_users,
            page => $page,
            has_next => $has_next,
        );
    }
}

## コメントしたユーザの獲得
sub comment_users {
    my ($self, $comments) = @_;
    
    defined $comments or croak "Required: comments";
    ## ユーザID
    my @user_ids = map { $_->user_id } @$comments;
    return if (!@user_ids);
    
    my $comment_users;
    ## ユーザを検索し、ハッシュ形式に変換
    for ( moco('User')->search(where => { id => {-in => [@user_ids]} }) ) {
        $comment_users->{$_->id} = $_;
    }
    return $comment_users;
}

## エントリを書いたユーザを取得
sub entry_users {
    my ($self, $user_ids) = @_;
    
    defined $user_ids or croak 'Required: user_ids';
    return if (!@$user_ids);
    
    my $entry_users;
    for ( moco('User')->search( where => { id => {-in => [@$user_ids]} } ) ) {
        $entry_users->{$_->id} = $_;
    }
    return $entry_users;
}


1;
