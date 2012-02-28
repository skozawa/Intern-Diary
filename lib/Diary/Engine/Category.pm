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
    
    my $id = $r->req->param('id');
    if ( !defined $id || $id eq "" ) {
        $r->res->redirect('/category.all');
        return;
    }
    
    my $category = moco('Category')->find(id => $id);
    my $entries = moco('Entry')->get_entry_by_category( cid => $id );
    my $entry_users = $self->entry_users($entries);
    
    $r->stash->param( 
        category => $category,
        entries => $entries,
        entry_users => $entry_users,
    );
}

## カテゴリの一覧
sub all : Public {
    my ($self, $r) = @_;
    
    my $categories = moco('Category')->categories;
    my $entries;
    my $user_ids;
    for my $category ( @$categories ) {
        my $entries_tmp = moco('Entry')->get_entry_by_category(cid => $category->id);
        $entries->{ $category->id } = $entries_tmp;
        map { push @$user_ids, $_->user_id } @$entries_tmp;
    }
    my $entry_users = $self->users($user_ids);
    
    $r->stash->param(
        categories => $categories,
        entries => $entries,
        entry_users => $entry_users,
    );
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
        my $entries = moco('Entry')->get_entry_by_category( cid => $id );
        
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
        return;
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
        my $entries = moco('Entry')->get_entry_by_category( cid => $id );
        
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
        return;
    }
}

## エントリを書いたユーザを取得
sub entry_users {
    my ($self, $entries) = @_;
    
    defined $entries or croak "Required: entries";
    
    my @user_ids = map { $_->user_id } @$entries;
    
    return $self->users(\@user_ids);
}

## user_idに該当するユーザを取得
sub users {
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
