#!/usr/bin/env perl
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
    del_comment => \&delete_comment,
    comments => \&list_comment,
    search => \&search_diary,
);

my $command = shift @ARGV || 'list';

my $user = moco('User')->find(name => $ENV{USER}) || moco('User')->create(name => $ENV{USER});
my $handler = $HANDLERS{ $command } or pod2usage;

$handler->($user, @ARGV);




## add
sub add_diary {
    my ($user, $title) = @_;
    
    defined $title && $title ne "" or die "Required title\nUsage: diary.pl add title [body]";
    
    my $body = join "", <STDIN>;
    chomp($body);
    defined $title && $title ne "" or die "Required body\nUsage: diary.pl add title [body]";
	
    my $diary = $user->add_diary(
        title => $title,
        body => $body,
    );
    
    print "add diary: ",$diary->id,"\n";;
}

## delete
sub delete_diary {
    my ($user, $diary_id) = @_;
	
	defined $diary_id && $diary_id ne "" or die "Required: diary_id\nUsage: diary.pl delete diary_id";
	
	my $diary = $user->delete_diary( diary_id => $diary_id );
	print 'deleted: ',$diary->as_string,"\n";
}

## list
sub list_diary {
    my ($user) = @_;
    
    my $entries = $user->diaries;
	foreach my $entry (@$entries) {
		print $entry->as_string, "\n";
	}
}

## edit
sub edit_diary {
    my ($user, $diary_id) = @_;
	
	defined $diary_id && $diary_id ne "" or die "Required: diary_id\nUsage: diary.pl edit diary_id [body]";
	my $entry = $user->diary($diary_id);
	
	print "------- Before -------\n";
	print $entry->as_string, "\n";
	print "-------  Edit  -------\n";
	print "Input tilte:\n";
	my $title = <STDIN>;
	chomp($title);
	defined $title && $title ne "" or die "Required: title\nUsage: diary.pl edit diary_id [body]";

	print "Input body:\n";
	my $body = join "", <STDIN>;
	chomp($body);
	defined $body && $body ne "" or die "Required: body\nUsage: diary.pl edit diary_id [body]";
	
	$entry->update_entry(
        title => $title,
        body => $body,
    );
	
	print "Updated: ",$entry->updated_on,"\n";
}

## comment
sub comment_diary {
    my ($user, $diary_id) = @_;
	
	defined $diary_id && $diary_id ne "" or die "Required: diary_id\nUsage: diary.pl comment diary_id [content]";
	moco("Entry")->has_entry($diary_id) or die "Not found diary\n";
	
	print "Input body:\n";
	my $content = join "", <STDIN>;
	chomp($content);
	defined $content && $content ne "" or die "Required: content\nUsage: diary.pl comment diary_id [content]";
	
	my $comment = $user->add_comment(
        diary_id => $diary_id,
        content => $content,
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
    
	my $comments = $user->comments;
	foreach my $comment (@$comments) {
		print $comment->as_string, "\n";
	}
}

sub search_diary {
    my ($user) = @_;
}




__END__

=head1 NAME

diary.pl - diary

=head1 SYNOPSIS

  diary.pl add title [body]

  diary.pl list

  diary.pl delete diary_id

  diary.pl edit diary_id [body]

  diary.pl comment diary_id [content]

  diary.pl del_comment comment_id

  diary.pl comments

=cut

