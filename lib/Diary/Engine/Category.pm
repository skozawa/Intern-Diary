package Diary::Engine::Category;
use strict;
use warnings;
use Diary::Engine -Base;

use Diary::MoCo;
use Carp qw(croak);

use XML::FeedPP;
use utf8;

## カテゴリの表示
sub default : Public {
    my ($self, $r) = @_;
    
    $r->req->form(
        id => ['NOT_BLANK','UINT'],
        page => ['UINT'],
    );
    
    if (not $r->req->form->has_error) {
        my $page = $r->req->param('page') || 1;
        my $limit = 5;
        
        my $id = $r->req->param('id');
        my $category = moco('Category')->find(id => $id);
        if ( !$category ) {
            $r->res->redirect('/category.all');
            return;
        }
        my ($entries, $entry_size) = moco('Entry')->get_entry_by_category( cid => $id, page => $page );
        my @user_ids = map { $_->user_id } @$entries;
        my $entry_users = $self->entry_users(\@user_ids);
        my $has_next = $page * $limit < $entry_size ? 1 : 0;
        
        $r->stash->param( 
            category => $category,
            entries => $entries,
            entry_users => $entry_users,
            page => $page,
            has_next => $has_next,
        );
    } else {
        $r->res->redirect('/category.all');
    }
}

## カテゴリの一覧
sub all : Public {
    my ($self, $r) = @_;
    
    $r->req->form(
        page => ['UINT'],
    );
    
    if (not $r->req->form->has_error) {
        my $page = $r->req->param('page') || 1;
        my $limit = 5;
        
        my $categories = moco('Category')->categories(page => $page);
        my $entries;
        my $user_ids;
        for my $category ( @$categories ) {
            my ($entries_tmp, $entry_size) = moco('Entry')->get_entry_by_category(cid => $category->id);
            $entries->{ $category->id } = $entries_tmp;
            map { push @$user_ids, $_->user_id } @$entries_tmp;
        }
        my $entry_users = $self->entry_users($user_ids);
        my $category_size = moco('Category')->count;
        my $has_next = $page * $limit < $category_size ? 1 : 0;
        
        $r->stash->param(
            categories => $categories,
            entries => $entries,
            entry_users => $entry_users,
            page => $page,
            has_next => $has_next,
        );
    } else {
        $r->res->redirect('/category.all');
    }
}

## RSSフィード
sub feed_rss : Public {
    my ($self, $r) = @_;
    
    $r->req->form(
        id => ['NOT_BLANK', 'UINT'],
    );
    
    if (not $r->req->form->has_error) {
        my $id = $r->req->param('id');
        
        my $category = moco('Category')->find(id => $id);
        my $entries = moco('Entry')->get_entry_by_category( cid => $id, limit => 10 );
        
        my $feed = XML::FeedPP::RSS->new();
        
        $feed->title($category->name);
        $feed->link($r->config->app_config('default')->{uri});
        $feed->description("カテゴリ「".$category->name."」の日記");
        
        foreach my $entry ( @$entries ) {
            $feed->add_item (
                link => $r->config->app_config('default')->{uri}.'diary?id='.$entry->id,
                title => $entry->title,
                description => (split(/\n/,$entry->body))[0],
                pubData => $entry->created_on->strftime('%Y-%m-%dT%H:%M:%S%z'),
            );
        }
        
        $r->res->content_type('application/xml');
        $r->res->content($feed->to_string('UTF-8'));
    } else {
        $r->res->redirect('/category.all');
    }
}

## Atomフィード
sub feed_atom : Public {
    my ($self, $r) = @_;
    
    $r->req->form(
        id => ['NOT_BLANK', 'UINT'],
    );
    
    if (not $r->req->form->has_error) {
        my $id = $r->req->param('id');
        
        my $category = moco('Category')->find(id => $id);
        my $entries = moco('Entry')->get_entry_by_category( cid => $id, limit => 10 );
        
        my $feed = XML::FeedPP::Atom::Atom10->new();
        
        $feed->title($category->name);
        $feed->link($r->config->app_config('default')->{uri});
        $feed->description("カテゴリ「".$category->name."」の日記");
        
        foreach my $entry ( @$entries ) {
            $feed->add_item (
                link => $r->config->app_config('default')->{uri}.'diary?id='.$entry->id,
                title => $entry->title,
                content => $entry->body,
                pubData => $entry->created_on->strftime('%Y-%m-%dT%H:%M:%S%z'),
                updated => $entry->updated_on->strftime('%Y-%m-%dT%H:%M:%S%z'),
            );
        }
        
        $r->res->content_type('application/xml');
        $r->res->content($feed->to_string('UTF-8'));
    } else {
        $r->res->redirect('/category.all');
    }
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
