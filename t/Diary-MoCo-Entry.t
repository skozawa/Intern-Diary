package t::Diary::MoCo::Entry;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Test::Exception;
use t::Diary;

use Diary::MoCo::User;
use Diary::MoCo::Entry;
use Diary::MoCo::Category;
use utf8;

sub startup : Test(startup){
    use_ok 'Diary::MoCo::Entry';
    t::Diary->truncate_db;
}


sub get_entry_by_category : Tests {
    ## テストユーザ作成
    ok my $user = Diary::MoCo::User->create(name => 'test_user_1'), 'create user';
    ## テスト用日記生成
    my @entries = (
        { title => "test1", body => "これはテストです", category => "" },
        { title => "test2", body => "今日は晴れです", category => "天気,日記" },
        { title => "test3", body => "今日は雪が降りました", category => "天気,冬" },
        { title => "test4", body => "MoCoの勉強中です", category => "MoCo"},
    );
    
    ## Entry1の追加
    my $entry1 = $user->add_entry(%{$entries[0]});
    $user->add_category(category => $entries[0]->{category}, entry_id => $entry1->id);
    ## Entry2の追加
    my $entry2 = $user->add_entry(%{$entries[1]});
    $user->add_category(category => $entries[1]->{category}, entry_id => $entry2->id);
    ## Entry3の追加
    my $entry3 = $user->add_entry(%{$entries[2]});
    $user->add_category(category => $entries[2]->{category}, entry_id => $entry3->id);
    ## Entry4の追加
    my $entry4 = $user->add_entry(%{$entries[3]});
    $user->add_category(category => $entries[3]->{category}, entry_id => $entry4->id);
    
    ## テスト用カテゴリ
    my @categories = ( "天気", "日記", "冬", "MoCo");
    
    ## カテゴリによる検索
    my ($entries1, $entry_size1) = Diary::MoCo::Entry->get_entry_by_category( cid => 1 );
    is_deeply $entries1->map( sub { $_->title } )->to_a, ['test2', 'test3'], 'search: category_id 1 title';
    
    my ($entries2, $entry_size2) = Diary::MoCo::Entry->get_entry_by_category( cid => 2 );
    is_deeply $entries2->map( sub { $_->body } )->to_a, ['今日は晴れです'], 'search: category_id 2 body';
    
    my ($entries3, $entry_size3) = Diary::MoCo::Entry->get_entry_by_category( cid => 3 );
    is_deeply $entries3->map( sub { $_->id } )->to_a, [3], 'search: category id 3 id';
    
    my ($entries4, $entry_size4) = Diary::MoCo::Entry->get_entry_by_category( cid => 4 );
    my @entry_ids4 = map { $_->id } @$entries4;
    my $relation4 = Diary::MoCo::Rel_entry_category->search(where => {entry_id => {-in => [@entry_ids4]}});
    is_deeply $relation4->map( sub { $_->category_id } )->to_a, [4], 'search: category id 4 category_ids';
    
    my ($entries5, $entry_size5) = Diary::MoCo::Entry->get_entry_by_category( cid => 10 );
    is $entries5, undef, 'search: category id undef';
    
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

