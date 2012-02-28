package t::Diary::MoCo::User;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Test::Exception;
use t::Diary;

use Diary::MoCo;
use Diary::MoCo::User;
use utf8;

sub startup : Test(startup) {
    use_ok 'Diary::MoCo::User';
    t::Diary->truncate_db;
}


sub t01_add_entry : Tests {
    ## テストユーザ作成
    ok my $user = Diary::MoCo::User->create(name => 'test_user_1'), 'create user';
    ## 初期状態
    is_deeply $user->entries->to_a, [], 'initial';
    
    ## 正常動作用
    my @entries = (
        { title => "test1", body => "これはテストです", category => "" },
        { title => "test2", body => "今日は晴れです", category => "天気,日記" },
        { title => "test3", body => "今日は雪が降りました", category => "天気,冬" },
        { title => "test4", body => "MoCoの勉強中です", category => "MoCo"},
    );
    
    ## Entry1の追加
    my $entry1 = $user->add_entry(%{$entries[0]});
    $user->add_category(category => $entries[0]->{category}, entry_id => $entry1->id);
    ## 返り値の確認
    isa_ok $entry1, 'Diary::MoCo::Entry';
    is $entry1->title, $entries[0]->{title}, '$entry1 title';
    is $entry1->body, $entries[0]->{body}, '$entry1 body';
    
    ## Entry2の追加
    my $entry2 = $user->add_entry(%{$entries[1]});
    $user->add_category(category => $entries[1]->{category}, entry_id => $entry2->id);
    is $entry2->body, $entries[1]->{body}, '$entry2 body';
    my $relation2 = Diary::MoCo::Rel_entry_category->search(where => {entry_id => $entry2->id});
    is_deeply $relation2->map( sub { $_->category_id } )->to_a, [1,2], '$entry2 category id';
    
    ## Entry3の追加
    my $entry3 = $user->add_entry(%{$entries[2]});
    $user->add_category(category => $entries[2]->{category}, entry_id => $entry3->id);
    is $entry3->title, $entries[2]->{title}, '$entry3 title';
    my $relation3 = Diary::MoCo::Rel_entry_category->search(where => {entry_id => $entry3->id});
    is_deeply $relation3->map( sub { $_->category_id } )->to_a, [1,3], '$entry3 category id';
    
    ## Entry4の追加
    my $entry4 = $user->add_entry(%{$entries[3]});
    $user->add_category(category => $entries[3]->{category}, entry_id => $entry4->id);
    is $entry4->body, $entries[3]->{body}, '$entry4 body';
    
    ## 異常動作用
    my @entries2 = (
        {title => "error_test"},
        {body => "これはテストです"},
        {category => "category1"},
        {title => "error_test4", body => ""},
        {body => "This is a test", category => "テスト"},
        {title => "error_test", category => "エラー"},
        {title => "", body => "", category => ""},
        {},
    );
    dies_ok {$user->add_entry(%$_);} 'dies_ok entry error' for @entries2;
    
    is $user->entry_size, 4, 'user entry_size';
    
    ## Entry追加後
    my @titles;
    push @titles, $entries[$_]->{title} for 0 .. $#entries;
    is_deeply $user->entries(limit => 4)->map(sub { $_->title } )->to_a, [ @titles ], ' $usr->entries->title ';
    my @bodies;
    push @bodies, $entries[$_]->{body} for 0 .. $#entries;
    is_deeply $user->entries(limit => 4)->map( sub { $_->body } )->to_a, [ @bodies ], '$user->entries->body';
}

sub t02_delete_entry : Tests {
    ## テストユーザの取得
    my $user = Diary::MoCo::User->find(name => 'test_user_1');
    
    ## 初期状態
    my @entry_titles = ( 'test1', 'test2', 'test3', 'test4' );
    is_deeply $user->entries(limit => 4)->map( sub { $_->title } )->to_a, [@entry_titles], 'initial entry title';
    is_deeply $user->entries(limit => 4)->map( sub { $_->id } )->to_a, [1,2,3,4], 'initial entry id';
    
    ## Entry1の削除
    my $entry1 = $user->delete_entry(entry_id => 1);
    isa_ok $entry1, 'Diary::MoCo::Entry';
    is $entry1->id, 1, '$entry1 id';
    is $entry1->title, $entry_titles[0], '$entry1 title';
    
    ## Entry3の削除
    my $entry3 = $user->delete_entry(entry_id => 3);
    is $entry3->id, 3, '$entry3 id';
    is $entry3->body, '今日は雪が降りました', '$entry3 body';
    
    ## 異常動作
    dies_ok { $user->delete_entry(); } 'dies_ok delete_entry nothing';
    dies_ok { $user->delete_entry( entry_id => -1 ); } 'dies_ok delete_entry minus';
    dies_ok { $user->delete_entry( entry_id => undef ); } 'dies_ok delete_entry undef';
    dies_ok { $user->delete_entry( entry_id => 20 ); } 'dies_ok delete_entry not found';
    
    my $user2 = Diary::MoCo::User->create(name => 'test_user_2'), 'create user';
    dies_ok { $user2->delete_entry( entry_id => 2 ); } 'dies_ok delete_entry another user';
    
    ## 削除後
    is_deeply $user->entries->map( sub { $_->id} )->to_a, [2,4], '$user->entries->id';
}


sub t03_edit_entry : Tests {
    ## テストユーザの取得
    my $user = Diary::MoCo::User->find(name => 'test_user_1');
    
    ## 初期状態
    my @entry_titles = ( 'test2', 'test4' );
    my @entry_bodies = ( '今日は晴れです', 'MoCoの勉強中です' );
    is_deeply $user->entries->map( sub { $_->title } )->to_a, [@entry_titles], 'initial entry title';
    is_deeply $user->entries->map( sub { $_->body } )->to_a, [@entry_bodies], 'initial entry body';
    is_deeply $user->entries->map( sub { $_->id } )->to_a, [2,4], 'initial entry id';
    
    ## Entry2の編集
    $entry_titles[0] = 'test';
    $entry_bodies[0] = '今日は雨でした';
    my $entry2 = $user->edit_entry(
        title => $entry_titles[0],
        body => $entry_bodies[0],
        category => '天気,雨',
        entry_id => 2,
    );
    isa_ok $entry2, 'Diary::MoCo::Entry';
    is $entry2->title, $entry_titles[0], '$entry2 title';
    is $entry2->body, $entry_bodies[0], '$entry2 body';
    my $relation2 = Diary::MoCo::Rel_entry_category->search(where => {entry_id => $entry2->id});
    is_deeply $relation2->map( sub { $_->category_id } )->to_a, [1,5], '$entry2 category id';
    
    ## 異常動作
    my @e_entries = (
        {},
        { title => "test", entry_id => 2 },
        { body => "今日は雨でした", entry_id => 2 },
        { category => "", entry_id => 2 },
        { title => "test", body => "test", category => "テスト"},
        { title => "test", body => "test", dentry_id => 2},
        { title => "test", category => "test", entry_id => 2},
        { body => "test", category => "test", entry_id => 2},
        { title => "", body => "", category => "", entry_id => 2},
        { title => undef, body => undef, category => undef, entry_id => 2},
        { title => "test", body => "test", category => "test", entry_id => 3},
    );
    dies_ok { $user->edit_entry(%$_); } 'dies_ok edit entry error_args' for @e_entries;
    
    dies_ok { $user->edit_entry( title => "test", body => "test",
                                 category => "test", entry_id => 3);} 'dies_ok edit entry not found';
    
    my $user2 = Diary::MoCo::User->find(name => 'test_user_2');
    dies_ok { $user2->edit_entry( title => "test", body => "test",
                                  category => "test", entry_id => 2); } 'dies_ok edit entry another user';
    
    ## 編集後
    is_deeply $user->entries->map( sub { $_->title } )->to_a, [@entry_titles], 'initial entry title';
    is_deeply $user->entries->map( sub { $_->body } )->to_a, [@entry_bodies], 'initial entry body';
    is_deeply $user->entries->map( sub { $_->id } )->to_a, [2,4], 'initial entry id';
}


sub t04_search_entry : Tests {
    ## テストユーザの取得
    my $user = Diary::MoCo::User->find(name => 'test_user_1');
    
    my @entry_titles = ( 'test', 'test4' );
    my @entry_bodies = ( '今日は雨でした', 'MoCoの勉強中です' );
    
    my @queries = ("雨", "MoCo", "test", "晴れ");
    
    ## Diaryの検索
    my $entries1 = $user->search_entry( query => $queries[0] );
    is_deeply $entries1->map( sub { $_->title } )->to_a, [$entry_titles[0]], 'search: query1 title';
    is_deeply $entries1->map( sub { $_->body } )->to_a, [$entry_bodies[0]], 'search: query1 body';
    
    my $entries2 = $user->search_entry( query => $queries[1] );
    is_deeply $entries2->map( sub { $_->body } )->to_a, [$entry_bodies[1]], 'search: query2 body';
    
    my $entries3 = $user->search_entry( query => $queries[2] );
    is_deeply $entries3->map( sub { $_->title } )->to_a, [@entry_titles], 'search: query3 title';
    is_deeply $entries3->map( sub { $_->id } )->to_a, [2,4], 'search: query3 id';
    
    my $entries4 = $user->search_entry( query => $queries[3] );
    is_deeply $entries4->map( sub { $_->id } )->to_a, [], 'search: query4 id';
    
    ## 異常動作
    dies_ok { $user->search_entry(); } 'dies_ok search not query';
    dies_ok { $user->serach_entry( query => "" ); } 'dies_ok search not query';
    dies_ok { $user->search_entry( query => undef ); } 'dies_ok search query undef';
}


sub t11_add_comment : Tests {
    ## テストユーザの取得
    my $user = Diary::MoCo::User->find(name => 'test_user_1');
    
    ## 初期状態
    is_deeply $user->comments->to_a, [], 'initial';
    
    #{ id => 2, title => "test", body => "今日は雨でした" }
    #{ id => 4, title => "test4", body => "MoCoの勉強中です"}
    
    my @comments = (
        "コメントテスト",
        "明日は晴れますよ",
        "MoCoは便利ですよ",
        "モコモコ",
        "明日は曇らしいですよ",
    );
    
    ## コメントの追加
    ## Comment1
    my $comment1 = $user->add_comment( entry_id => 2, content => $comments[0] );
    isa_ok $comment1, 'Diary::MoCo::Comment';
    is $comment1->content, $comments[0], '$comment1 content';
    is $comment1->entry_id, 2, '$comment1 id';
    
    ## Comment2
    my $comment2 = $user->add_comment( entry_id => 2, content => $comments[1] );
    is $comment2->content, $comments[1], '$comment2 content';
    
    ## Comment3
    my $comment3 = $user->add_comment( entry_id => 4, content => $comments[2] );
    is $comment3->content, $comments[2], '$comment3 content';
    
    ## Comment4
    my $comment4 = $user->add_comment( entry_id => 4, content => $comments[3] );
    is $comment4->content, $comments[3], '$comment4 content';
    
    ## Comment5
    my $comment5 = $user->add_comment( entry_id => 2, content => $comments[4] );
    is $comment5->content, $comments[4], '$comment5 content';
    
    ## 異常動作
    dies_ok { $user->add_comment(); } 'add_comment: require content and entry_id';
    dies_ok { $user->add_comment( content => "てすと" ); } 'add_comment: require entry_id';
    dies_ok { $user->add_comment( entry_id => 4, content => "" ); } 'add_comment: require content';
    dies_ok { $user->add_comment( entry_id => 10, content => "テスト" ); } 'add_comment: not found entry';

    ## コメント追加後
    is_deeply $user->comments->map( sub { $_->content } )->to_a, [@comments], '$user->comments->title';
    is_deeply $user->comments->map( sub { $_->entry_id } )->to_a, [2,2,4,4,2], '$user->comments->entry_id';
}


sub t12_delete_comment {
    ## テストユーザの取得
    my $user = Diary::MoCo::User->find(name => 'test_user_1');
    
    my @comments = (
        "コメントテスト", #1
        "明日は晴れますよ", #2
        "MoCoは便利ですよ", #3
        "モコモコ", #4
        "明日は曇らしいですよ", #5
    );
    
    ## 初期状態
    is_deeply $user->comments->map(sub { $_->content } )->to_a, [@comments], 'initial';
    
    ## コメントの削除
    my $comment1 = $user->delete_comment( comment_id => 1 );
    isa_ok $comment1, 'Diary::MoCo::Comment';
    is $comment1->content, $comments[0], '$comment1->content';
    is $comment1->id, 1, '$comment1->id';
    
    my $comment4 = $user->delete_comment( comment_id => 4 );
    is $comment4->content, $comments[3], '$comment4->content';
    
    ## 異常動作
    dies_ok { $user->delete_comment(); } 'dies_ok delete_comment: require comment_id';
    dies_ok { $user->delete_comment( comment_id => 1 ); } 'dies_ok delete_comment: not found comment';
    
    my $user2 = Diary::MoCo::User->find(name => 'test_user_2');
    dies_ok { $user2->delete_comment( comment_id => 2 ); } 'dies_ok delete_comment: not your comment';
    
    ## コメント削除後
    is_deeply $user->comments->map( sub { $_->id } )->to_a, [2,3,5], '$user->comments->id';
    is_deeply $user->comments->map( sub { $_->content })->to_a, [@comments[1,2,4]], '$user->comments->content';
    is_deeply $user->comments->map( sub { $_->entry_id })->to_a, [2,2,4], '$user->comments->entry_id';
}



__PACKAGE__->runtests;

1;
