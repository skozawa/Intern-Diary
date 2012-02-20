package t::Diary::MoCo::Entry;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Test::Exception;
use t::Diary;

use Diary::MoCo::Entry;
use Diary::MoCo::Category;
use utf8;

sub startup : Test(startup){
    use_ok 'Diary::MoCo::Entry';
    t::Diary->truncate_db;
}


sub get_entry_by_category : Tests {
    ## テスト用日記生成
    my @diaries = (
                   { title => "test1", body => "これはテストです", category_ids => "", user_id => 1},
                   { title => "test2", body => "今日は晴れです", category_ids => "1,2", user_id => 1 },
                   { title => "test3", body => "今日は雪が降りました", category_ids => "1,3", user_id => 1 },
                   { title => "test4", body => "MoCoの勉強中です", category_ids => "4", user_id => 1},
    );
    ok my $diary = Diary::MoCo::Entry->create(%$_), 'create entry' for @diaries;
    ## テスト用カテゴリ生成
    my @categories = ( "天気", "日記", "冬", "MoCo");
    ok my $category = Diary::MoCo::Category->create( name => $_ ), 'create category' for @categories;
    
    ## カテゴリによる検索
    my $entries1 = Diary::MoCo::Entry->get_entry_by_category( cid => 1 );
    is_deeply $entries1->map( sub { $_->title } )->to_a, ['test2', 'test3'], 'search: category_id 1 title';
    
    my $entries2 = Diary::MoCo::Entry->get_entry_by_category( cid => 2 );
    is_deeply $entries2->map( sub { $_->body } )->to_a, ['今日は晴れです'], 'search: category_id 2 body';
    
    my $entries3 = Diary::MoCo::Entry->get_entry_by_category( cid => 3 );
    is_deeply $entries3->map( sub { $_->id } )->to_a, [3], 'search: category id 3 id';
    
    my $entries4 = Diary::MoCo::Entry->get_entry_by_category( cid => 4 );
    is_deeply $entries4->map( sub { $_->category_ids } )->to_a, [4], 'search: category id 4 category_ids';
    
    my $entries5 = Diary::MoCo::Entry->get_entry_by_category( cid => 10 );
    is_deeply $entries5->map( sub { $_->id } )->to_a, [], 'search: category id undef';
    
    ## 異常動作
    dies_ok { Diary::MoCo::Entry->get_entry_by_category(); } 'dies_ok: not args';
    dies_ok { Diary::MoCo::Entry->get_entry_by_category( cid => "" ); } 'dies_ok: require category_id';
}


sub updated_on : Test(1) {
    my $e = Diary::MoCo::Entry->create;
    no warnings 'once';
    local *DateTime::now = sub {
        my $class = shift;
        return DateTime->new(year => 1970, month => 1, day => 1, @_ );
    };
    $e->title('hoge');
    is $e->updated_on . '', '1970-01-01T00:00:00', 'updated';
}

__PACKAGE__->runtests;

1;

