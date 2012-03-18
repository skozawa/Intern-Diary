package Diary::Engine::API::Index;
use strict;
use warnings;
use Diary::Engine -Base;
use JSON::XS;
use Diary::MoCo;

sub default : Public {
    my ($self, $r) = @_;
    
    $r->req->form(
        page => ['NOT_BLANK','UINT'],
    );
    
    if (not $r->req->form->has_error) {
        my $page = $r->req->param('page');
        my $limit = 3;
        
        my $entries = $r->user->entries(page => $page);
        my $entry_size = $r->user->entry_size;
        my $has_pre = $page * $limit < $entry_size ? 'true' : 'false';
        
        ## JSON用ハッシュの生成
        my $data = {
            entries => {},
            page => $page,
            has_pre => $has_pre,
        };
        foreach my $entry ( @$entries ) {
            $data->{entries}->{$entry->id} = {
                "title" => $entry->title,
                #categories => {},
                "body" => $entry->body,
                "created_on" => $entry->created_on->datetime,
            };
            my $categories = {};
            foreach my $category ( @{$entry->categories} ) {
                $categories->{$category->id} = {
                    name => $category->name,
                };
            }
            $data->{entries}->{$entry->id}->{categories} = $categories;
        }
        
        $r->res->content_type('application/json');
        $r->res->content(encode_json $data);
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
        
        ## JSON用ハッシュの生成
        my $data = {
            id => $entry->id,
            title => $entry->title,
            categories => {},
            body => $entry->body,
            created_on => $entry->created_on->datetime,
        };
        foreach my $category ( @{$entry->categories} ) {
            $data->{categories}->{$category->id} = $category->name;
        }
        
        $r->res->content_type('application/json');
        $r->res->content(encode_json $data);
    }
}


## エントリの削除
sub delete : Public {
    my ($self, $r) = @_;
    
    my $id = $r->req->param('id');
    my $entry = $id ? moco('Entry')->find( id => $id, user_id => $r->user->id ) : undef;
    
    ## エントリの確認
    if ( !$entry ) {
        $r->res->redirect('/');
        return;
    }
    
    $r->follow_method;
}

sub _delete_post {
    my ($self, $r) = @_;
    
    $r->req->form(
        id => ['NOT_BLANK','UINT'],
    );
    
    if (not $r->req->form->has_error) {
        $r->user->delete_entry(entry_id => $r->req->param('id'));
    }
}

## エントリの編集
sub edit : Public {
    my ($self, $r) = @_;
    
    my $id = $r->req->param('id');
    my $entry = $id ? moco('Entry')->find( id => $id, user_id => $r->user->id ) : undef;
    
    if ( !$entry ) {
        $r->res->redirect('/');
        return;
    }
    
    $r->follow_method;
}

sub _edit_get {
}

sub _edit_post {
    my ($self, $r) = @_;
    
    $r->req->form(
        id => ['NOT_BLANK', 'UINT'],
        title => ['NOT_BLANK'],
        body => ['NOT_BLANK'],
    );
    
    if (not $r->req->form->has_error) {
        my $id = $r->req->param('id');
        my $title = $r->req->param('title');
        my $category = $r->req->param('category');
        my $body = $r->req->param('body');
        
        my $entry = $r->user->edit_entry (
            entry_id => $id,
            title => $title,
            body => $body,
            category => $category,
        );
        
        ## JSON用ハッシュの生成
        my $data = {
            id => $entry->id,
            title => $entry->title,
            categories => {},
            body => $entry->body,
            created_on => $entry->created_on->datetime,
        };
        foreach my $category ( @{$entry->categories} ) {
            $data->{categories}->{$category->id} = $category->name;
        }
        
        $r->res->content_type('application/json');
        $r->res->content(encode_json $data);
    }
}

1;
