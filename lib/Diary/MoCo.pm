package Diary::MoCo;

use strict;
use warnings;
use base 'DBIx::MoCo';
use Diary::DataBase;
use DateTime;
use DateTime::Format::MySQL;
use UNIVERSAL::require;
use Exporter::Lite;

our @EXPORT = qw(moco);

__PACKAGE__->db_object('Diary::DataBase');

__PACKAGE__->inflate_column (
    created_on => {
        inflate => sub {
            my $value = shift;
            return $value eq '0000-00-00 00:00:00' ? undef : DateTime::Format::MySQL->parse_datetime($value);
        },
        delfate => sub {
            my $dt = shift;
            return DateTime::Format::MySQL->format_datetime($dt);
        }
    }
);

__PACKAGE__->inflate_column (
    updated_on => {
        inflate => sub {
            my $value = shift;
            return $value eq '0000-00-00 00:00:00' ? undef : DateTime::Format::MySQL->parse_datetime($value);
        },
        delfate => sub {
            my $dt = shift;
            return DateTime::Format::MySQL->format_datetime($dt);
        }
    }
);


__PACKAGE__->add_trigger (
    before_create => sub {
        my ($class, $args) = @_;
        foreach my $col (qw(created_on updated_on)) {
            if ($class->has_column($col) && !defined $args->{$col}) {
                $args->{$col} = $class->now.q();
            }
        }
    }
);

__PACKAGE__->add_trigger(
    before_update => sub {
        my ($class, $self, $args) = @_;
        foreach my $col (qw(updated_on)) {
            if ($class->has_column($col) && !defined $args->{$col}) {
                $args->{$col} = $class->now.q();
            }
        }
    }
);


sub moco {
    my $moco = join '::', __PACKAGE__, @_;
    $moco->require or die $@;
    return $moco;
}

sub now {
    my $dt = DateTime->now(
        time_zone => 'UTC',
        formatter => 'DateTime::Format::MySQL',
    );
    return $dt;
}


sub has_row {
	my ($self, %args) = @_;
	
	if (defined $self->find(%args)) {
		return 1;
	} else {
		return 0;
	}
}



1;
