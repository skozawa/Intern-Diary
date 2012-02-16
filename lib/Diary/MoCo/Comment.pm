package Diary::MoCo::Comment;

use strict;
use warnings;

use base 'Diary::MoCo';

__PACKAGE__->table('comment');

__PACKAGE__->utf8_columns('content');

1;
