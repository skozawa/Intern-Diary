#!/usr/bin/env perl
use strict;
use warnings;

use lib "lib", glob "modules/*/lib";
use Diary::MoCo;
use Pod::Usage;
use Encode::Locale;
use Getopt::Long;

binmode STDOUT, ':encoding(console_out)';

my %HANDLERS = (
    add => \&add_entry,
    delete => \&delete_entry,
    list => \&list_entry,
    edit => \&edit_entry,
    show => \&show_entry,
    search => \&search_entry,
    categories => \&list_category,
    list_cid => \&list_entry_of_category,
    comment => \&comment_entry,
    del_comment => \&delete_comment,
    comments => \&list_comment,
);

my $opts = {
    'page' => 1,
    'limit' => 5,
};
GetOptions($opts, 'page=i', 'limit=i');

my $command = shift @ARGV || '';

my $handler = $HANDLERS{ $command } or pod2usage;
my $user = moco('User')->find(name => $ENV{USER}) || moco('User')->create(name => $ENV{USER});

$handler->($user, @ARGV);




## add
sub add_entry {
    my ($user, $title) = @_;
    
    defined $title && $title ne "" or die "Required title\nUsage: diary.pl add title [body]";
    
    print "Input category (separete ','):\n";
    my $category = input_line();
    
    print "Input body:\n";
    my $body = input_lines();
    defined $title && $title ne "" or die "Required body\nUsage: diary.pl add title [body]";
    
    my $entry = $user->add_entry(
        title => $title,
        body => $body,
    );
    
    $user->add_category(
        category => $category,
        entry_id => $entry->id,
    );
    
    print "add entry: ",$entry->id,"\n";;
}

## delete
sub delete_entry {
    my ($user, $entry_id) = @_;
    
    defined $entry_id && $entry_id ne "" or die "Required: entry_id\nUsage: diary.pl delete entry_id";
    
    my $entry = $user->delete_entry( entry_id => $entry_id );
    print 'deleted: ',$entry->as_string,"\n";
}

## list
sub list_entry {
    my ($user) = @_;
    
    my $entries = $user->entries(%$opts);
    foreach my $entry (@$entries) {
        print $entry->as_string, "\n";
    }
}

## edit
sub edit_entry {
    my ($user, $entry_id) = @_;
    
    defined $entry_id && $entry_id ne "" or die "Required: entry_id\nUsage: diary.pl edit entry_id [body]";
    my $entry = moco('Entry')->find(id => $entry_id, user_id => $user->id);
    
    print "------- Before -------\n";
    print $entry->as_string, "\n";
    print "-------  Edit  -------\n";
    print "Input tilte:\n";
    my $title = input_line();
    defined $title && $title ne "" or die "Required: title\nUsage: diary.pl edit entry_id [body]";
    
    print "Input category (separete ','):\n";
    my $category = input_line();
    
    print "Input body:\n";
    my $body = input_lines();
    defined $body && $body ne "" or die "Required: body\nUsage: diary.pl edit entry_id [body]";
    
    my $new_entry = $user->edit_entry(
        entry_id => $entry_id,
        title => $title,
        category => $category,
        body => $body,
    );
    print "Updated: ",$new_entry->updated_on,"\n";
}

## show
sub show_entry {
    my ($user, $entry_id) = @_;
    defined $entry_id && $entry_id ne "" or die "Required: entry_id\nUsage: diary.pl edit entry_id [body]";
    my $entry = $user->entry($entry_id);
    
    print "---- Entry ----\n";
    print $entry->as_string, "\n";
    print "---- Comment ----\n";
    my $comments = $entry->comments(%$opts);
    foreach my $comment (@$comments) {
        print $comment->as_string, "\n";
    }
}

## search
sub search_entry {
    my ($user, $query) = @_;
    
    defined $query && $query ne "" or die "Required: query\nUsage: diary.pl search query";
    
    my $entries = $user->search_entry(query => $query, %$opts);
    foreach my $entry (@$entries) {
        print $entry->as_string, "\n";
    }
}


## categires
sub list_category {
    my $categories = moco("Category")->categories;
    foreach my $category (@$categories) {
        print $category->as_string, "\n";
    }
}

## list_cid
sub list_entry_of_category {
    my ($user, $category_id) = @_;
    
    defined $category_id && $category_id ne "" or die "Required: category_id\nUsage: diary.pl list_cid category_id";
    
    my $entries = moco("Entry")->get_entry_by_category(
        cid => $category_id,
        %$opts,
    );
    foreach my $entry (@$entries) {
        print $entry->as_string, "\n";
    }
}

## comment
sub comment_entry {
    my ($user, $entry_id) = @_;
    
    defined $entry_id && $entry_id ne "" or die "Required: entry_id\nUsage: diary.pl comment entry_id [content]";
    moco("Entry")->has_row(id => $entry_id) or die "Not found entry\n";
    
    print "Input body:\n";
    my $content = input_lines();
    defined $content && $content ne "" or die "Required: content\nUsage: diary.pl comment entry_id [content]";
    
    my $comment = $user->add_comment(
        entry_id => $entry_id,
        content => $content,
        %$opts,
    );
}

## del_comment
sub delete_comment {
    my ($user, $comment_id) = @_;
    
    defined $comment_id && $comment_id ne "" or die "Required: comment_id\nUsage: diary.pl del_comment comment_id";
    
    my $comment = $user->delete_comment( comment_id => $comment_id );
    print 'deleted: ',$comment->as_string,"\n";
}

## comments
sub list_comment {
    my ($user) = @_;
    
    my $comments = $user->comments(%$opts);
    foreach my $comment (@$comments) {
        print $comment->as_string, "\n";
    }
}



sub input_line {
    my $input = <STDIN>;
    chomp($input);
    return $input;
}

sub input_lines {
    my $input = join "", <STDIN>;
    chomp($input);
    return $input;
}


__END__

=head1 NAME

diary.pl - diary

=head1 SYNOPSIS

  diary.pl add title [category] [body]
  diary.pl list
  diary.pl delete entry_id
  diary.pl edit entry_id [title] [category] [body]
  diary.pl show entry_id
  diary.pl search query
  diary.pl categories
  diary.pl list_cid category_id
  diary.pl comment entry_id [content]
  diary.pl del_comment comment_id
  diary.pl comments

=cut

