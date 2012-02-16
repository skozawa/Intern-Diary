use strict;
use warnings;

use lib "lib", glob "modules/*/lib";
use Diary::MoCo;
use Pod::Usage;
use Encode::Locale;


binmode STDOUT, ':encoding(console_out)';

my %HANDLERS = (
                add => \&add_diary,
                delete => \&delete_diary,
                list => \&list_diary,
                edit => \&edit_diary,
                
                comment => \&comment_diary,
                search => \&search_diary,
);

my $command = shift @ARGV || 'list';

#my $user = moco('User')->find(name => $ENV{USER}) || moco('USER')->create(name => $ENV{USER});
#my $handler = $HANDLERS{ $commend } or pod2usage;

#$handler->($user, @ARGV);


exit 0;


sub add_diary {
  
}

sub delete_diary {
  
}

sub list_diary {
  
}

sub edit_diary {
  
}

sub comment_diary {
  
}

sub search_diary {
  
}
