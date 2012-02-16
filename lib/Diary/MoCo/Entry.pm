package Diary::MoCo;;Entry;

use strict;
use warnings;

use base 'Diary::MoCo';

__PACKAGE__->table('entry');

__PACKAGE__->utf8_columns(qw(title body));

1;
