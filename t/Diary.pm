package t::Diary;
use strict;
use warnings;
use lib 'lib', glob 'modules/*/lib';
use Diary::DataBase;

Diary::DataBase->dsn('dbi:mysql:dbname=intern_diary_test');

sub truncate_db {
    Diary::DataBase->execute("TRUNCATE TABLE $_") for qw(user entry comment category);
}


1;
