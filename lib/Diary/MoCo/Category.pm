package Diary::MoCo::Category;

use strict;
use warnings;

use base 'Diary::MoCo';

__PACKAGE__->table('category');

__PACAKGE__->utf8_columns(qw(name));

1;

