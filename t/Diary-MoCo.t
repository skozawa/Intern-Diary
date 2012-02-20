package t::Diary::MoCo;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use t::Diary;


sub startup : Test {
    use_ok 'Diary::MoCo';
}

__PACKAGE__->runtests;


1;
