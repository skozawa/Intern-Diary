package Diary::Engine::Index;
use strict;
use warnings;
use Diary::Engine -Base;

use Diary::MoCo;
use Plack::Session;

## ユーザのエントリ一覧
sub default : Public {
    my ($self, $r) = @_;
    
    if (my $user = $r->user) {
        $r->req->form(
            page => ['UINT'],
        );

        if (not $r->req->form->has_error) {
            my $page = $r->req->param('page') || 1;
            my $limit = 3;
            
            my $entries = $user->entries(page => $page);
            my $entry_size = $user->entry_size;
            my $has_pre = $page * $limit < $entry_size ? 1 : 0;
            
            $r->stash->param(
                entries => $entries,
                page => $page,
                has_pre => $has_pre,
            );
        } else {
            $r->res->redirect('/');
        }
    }
}

## ログイン
sub login : Public {
    my ($self, $r) = @_;
    
    if ( my $user = $r->user ) {
        $r->res->redirect("/");
        return;
    }
}

## ログアウト
sub logout : Public {
    my ($self, $r) = @_;
    
    my $session = Plack::Session->new($r->req->env);
    $session->expire;
    
    $r->res->redirect('/index.login');
}

## 管理画面
sub mypage : Public {
    my ($self, $r) = @_;
    
    if (my $user = $r->user) {
        $r->req->form(
            page => ['UINT'],
         );

        if (not $r->req->form->has_error) {
            my $page = $r->req->param('page') || 1;
            my $limit = 5;
            
            my $entries = $r->user->entries(page => $page, limit => $limit);
            my $entry_size = $r->user->entry_size;
            my $has_pre = $page * $limit < $entry_size ? 1 : 0;
            
            $r->stash->param(
                entry_size => $entry_size,
                entries => $entries,
                page => $page,
                has_pre => $has_pre,
            );
        } else {
            $r->res->redirect('/index.mypage');
        }
    }
}


1;
