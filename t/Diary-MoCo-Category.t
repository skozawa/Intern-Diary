package t::Diary::MoCo::Category;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Test::Exception;
use t::Diary;
use utf8;

sub startup : Test(startup) {
    use_ok 'Diary::MoCo::Category';
    t::Diary->truncate_db;
}

sub categories : Tests {
    ## テスト用カテゴリ生成
    my @categories = ( "天気", "日記", "冬", "MoCo");
    ok my $category = Diary::MoCo::Category->create( name => $_ ), 'create category' for @categories;
    
    my $categories = Diary::MoCo::Category->categories;
    is_deeply $categories->map( sub { $_->name } )->to_a, [@categories], '$categories->name';
}

__PACKAGE__->runtests;

1;

