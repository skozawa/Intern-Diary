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
    is_deeply $user->diaries->to_a, [], 'initial';
    
    ## 正常動作用
    my @diaries = (
                   { title => "test1", body => "これはテストです", category => "" },
                   { title => "test2", body => "今日は晴れです", category => "天気,日記" },
                   { title => "test3", body => "今日は雪が降りました", category => "天気,冬" },
                   { title => "test4", body => "MoCoの勉強中です", category => "MoCo"},
    );
    
    ## Diary1の追加
    my $diary1 = $user->add_diary(%{$diaries[0]});
    ## 返り値の確認
    isa_ok $diary1, 'Diary::MoCo::Entry';
    is $diary1->title, $diaries[0]->{title}, '$diary1 title';
    is $diary1->body, $diaries[0]->{body}, '$diary1 body';
    
    ## Diary2の追加
    my $diary2 = $user->add_diary(%{$diaries[1]});
    is $diary2->body, $diaries[1]->{body}, '$diary2 body';
    is $diary2->category_ids, '1,2', '$diary2 category_ids';
    
    ## Diary3の追加
    my $diary3 = $user->add_diary(%{$diaries[2]});
    is $diary3->title, $diaries[2]->{title}, '$diary3 title';
    is $diary3->category_ids, '1,3', '$diary3 category_ids';
    
    ## Diary4の追加
    my $diary4 = $user->add_diary(%{$diaries[3]});
    is $diary4->body, $diaries[3]->{body}, '$diary4 body';

    ## 異常動作用
    my @diaries2 = (
                    {title => "error_test"},
                    {body => "これはテストです"},
                    {category => "category1"},
                    {title => "error_test4", body => ""},
                    {body => "This is a test", category => "テスト"},
                    {title => "error_test", category => "エラー"},
                    {title => "", body => "", category => ""},
                    {},
    );
    dies_ok {$user->add_diaries(%$_);} 'dies_ok diary error' for @diaries2;
    
    ## Diary追加後
    my @titles;
    push @titles, $diaries[$_]->{title} for 0 .. $#diaries;
    is_deeply $user->diaries->map(sub { $_->title } )->to_a, [ @titles ], ' $usr->diaries->title ';
    my @bodies;
    push @bodies, $diaries[$_]->{body} for 0 .. $#diaries;
    is_deeply $user->diaries->map( sub { $_->body } )->to_a, [ @bodies ], '$user->diaries->body';
}

sub t02_delete_diary : Tests {
    ## テストユーザの取得
    my $user = Diary::MoCo::User->find(name => 'test_user_1');
    
    ## 初期状態
    my @diary_titles = ( 'test1', 'test2', 'test3', 'test4' );
    is_deeply $user->diaries->map( sub { $_->title } )->to_a, [@diary_titles], 'initial diary title';
    is_deeply $user->diaries->map( sub { $_->id } )->to_a, [1,2,3,4], 'initial diary id';
    
    ## Diary1の削除
    my $diary1 = $user->delete_diary(diary_id => 1);
    isa_ok $diary1, 'Diary::MoCo::Entry';
    is $diary1->id, 1, '$diary1 id';
    is $diary1->title, $diary_titles[0], '$diary1 title';
    
    ## Diary3の削除
    my $diary3 = $user->delete_diary(diary_id => 3);
    is $diary3->id, 3, '$diary3 id';
    is $diary3->body, '今日は雪が降りました', '$diary3 body';
    
    ## 異常動作
    dies_ok { $user->delete_diary(); } 'dies_ok delete_diary nothing';
    dies_ok { $user->delete_diary( diary_id => -1 ); } 'dies_ok delete_diary minus';
    dies_ok { $user->delete_diary( diary_id => undef ); } 'dies_ok delete_diary undef';
    dies_ok { $user->delete_diary( diary_id => 20 ); } 'dies_ok delete_diary not found';
    
    my $user2 = Diary::MoCo::User->create(name => 'test_user_2'), 'create user';
    dies_ok { $user2->delete_diary( diary_id => 2 ); } 'dies_ok delete_diary another user';
    
    ## 削除後
    is_deeply $user->diaries->map( sub { $_->id} )->to_a, [2,4], '$user->diaries->id';
}


sub t03_edit_diary : Tests {
    ## テストユーザの取得
    my $user = Diary::MoCo::User->find(name => 'test_user_1');
    
    ## 初期状態
    my @diary_titles = ( 'test2', 'test4' );
    my @diary_bodies = ( '今日は晴れです', 'MoCoの勉強中です' );
    is_deeply $user->diaries->map( sub { $_->title } )->to_a, [@diary_titles], 'initial diary title';
    is_deeply $user->diaries->map( sub { $_->body } )->to_a, [@diary_bodies], 'initial diary body';
    is_deeply $user->diaries->map( sub { $_->id } )->to_a, [2,4], 'initial diary id';
    
    ## Diary2の編集
    $diary_titles[0] = 'test';
    $diary_bodies[0] = '今日は雨でした';
    my $diary2 = $user->edit_diary(
        title => $diary_titles[0],
        body => $diary_bodies[0],
        category => '天気,雨',
        diary_id => 2,
    );
    isa_ok $diary2, 'Diary::MoCo::Entry';
    is $diary2->title, $diary_titles[0], '$diary2 title';
    is $diary2->body, $diary_bodies[0], '$diary2 body';
    is $diary2->category_ids, '1,5', '$diary2 category_ids';
    
    ## 異常動作
    my @e_diaries = (
                     {},
                     { title => "test", diary_id => 2 },
                     { body => "今日は雨でした", diary_id => 2 },
                     { category => "", diary_id => 2 },
                     { title => "test", body => "test", category => "テスト"},
                     { title => "test", body => "test", diary_id => 2},
                     { title => "test", category => "test", diary_id => 2},
                     { body => "test", category => "test", diary_id => 2},
                     { title => "", body => "", category => "", diary_id => 2},
                     { title => undef, body => undef, category => undef, diary_id => 2},
                     { title => "test", body => "test", category => "test", diary_id => 3},
    );
    dies_ok { $user->edit_diary(%$_); } 'dies_ok edit diary error_args' for @e_diaries;
    
    dies_ok { $user->edit_diary( title => "test", body => "test",
                                 category => "test", diary_id => 3);} 'dies_ok edit diary not found';
    
    my $user2 = Diary::MoCo::User->find(name => 'test_user_2');
    dies_ok { $user2->edit_diary( title => "test", body => "test",
                                  category => "test", diary_id => 2); } 'dies_ok edit diary another user';
    
    ## 編集後
    is_deeply $user->diaries->map( sub { $_->title } )->to_a, [@diary_titles], 'initial diary title';
    is_deeply $user->diaries->map( sub { $_->body } )->to_a, [@diary_bodies], 'initial diary body';
    is_deeply $user->diaries->map( sub { $_->id } )->to_a, [2,4], 'initial diary id';
}


sub t04_search_diary : Tests {
    ## テストユーザの取得
    my $user = Diary::MoCo::User->find(name => 'test_user_1');
    
    my @diary_titles = ( 'test', 'test4' );
    my @diary_bodies = ( '今日は雨でした', 'MoCoの勉強中です' );
    
    my @queries = ("雨", "MoCo", "test", "晴れ");
    
    ## Diaryの検索
    my $diaries1 = $user->search_diary( query => $queries[0] );
    is_deeply $diaries1->map( sub { $_->title } )->to_a, [$diary_titles[0]], 'search: query1 title';
    is_deeply $diaries1->map( sub { $_->body } )->to_a, [$diary_bodies[0]], 'search: query1 body';
    
    my $diaries2 = $user->search_diary( query => $queries[1] );
    is_deeply $diaries2->map( sub { $_->body } )->to_a, [$diary_bodies[1]], 'search: query2 body';
    
    my $diaries3 = $user->search_diary( query => $queries[2] );
    is_deeply $diaries3->map( sub { $_->title } )->to_a, [@diary_titles], 'search: query3 title';
    is_deeply $diaries3->map( sub { $_->id } )->to_a, [2,4], 'search: query3 id';
    
    my $diaries4 = $user->search_diary( query => $queries[3] );
    is_deeply $diaries4->map( sub { $_->id } )->to_a, [], 'search: query4 id';
    
    ## 異常動作
    dies_ok { $user->search_diary(); } 'dies_ok search not query';
    dies_ok { $user->serach_diary( query => "" ); } 'dies_ok search not query';
    dies_ok { $user->search_diary( query => undef ); } 'dies_ok search query undef';
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
    my $comment1 = $user->add_comment( diary_id => 2, content => $comments[0] );
    isa_ok $comment1, 'Diary::MoCo::Comment';
    is $comment1->content, $comments[0], '$comment1 content';
    is $comment1->diary_id, 2, '$comment1 id';
    
    ## Comment2
    my $comment2 = $user->add_comment( diary_id => 2, content => $comments[1] );
    is $comment2->content, $comments[1], '$comment2 content';
    
    ## Comment3
    my $comment3 = $user->add_comment( diary_id => 4, content => $comments[2] );
    is $comment3->content, $comments[2], '$comment3 content';
    
    ## Comment4
    my $comment4 = $user->add_comment( diary_id => 4, content => $comments[3] );
    is $comment4->content, $comments[3], '$comment4 content';
    
    ## Comment5
    my $comment5 = $user->add_comment( diary_id => 2, content => $comments[4] );
    is $comment5->content, $comments[4], '$comment5 content';
    
    ## 異常動作
    dies_ok { $user->add_comment(); } 'add_comment: require content and diary_id';
    dies_ok { $user->add_comment( content => "てすと" ); } 'add_comment: require diary_id';
    dies_ok { $user->add_comment( diary_id => 4, content => "" ); } 'add_comment: require content';
    dies_ok { $user->add_comment( diary_id => 10, content => "テスト" ); } 'add_comment: not found diary';

    ## コメント追加後
    is_deeply $user->comments->map( sub { $_->content } )->to_a, [@comments], '$user->comments->title';
    is_deeply $user->comments->map( sub { $_->diary_id } )->to_a, [2,2,4,4,2], '$user->comments->diary_id';
}


sub t12_delete_comment {
    ## テストユーザの取得
    my $user = Diary::MoCo::User->find(name => 'test_user_1');
    
    my @comments = (
        "コメントテスト", # -> 2
        "明日は晴れますよ", # -> 2
        "MoCoは便利ですよ", # -> 4
        "モコモコ", # -> 4
        "明日は曇らしいですよ", # -> 2
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
    is_deeply $user->comments->map( sub { $_->diary_id })->to_a, [2,2,4], '$user->comments->diary_id';
}



__PACKAGE__->runtests;

1;
