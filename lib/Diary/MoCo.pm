package Diary::MoCo;

use strict;
use warnings;
use base 'DBIx::MoCo';
use Diary::DataBase;

__PACKAGE__->db_object('Diary::DataBase');


__PACKAGE__->add_trigger (
                          before_create => sub {
                              my ($class, $args) = @_;
                              foreach my $col (qw(created_on updated_on)) {
                                  if ($class->has_column($col) && !defined $args->{$col}) {
                                      $args->{$col} = $class->now . '';
                                  }
                              }
                          }
);


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

1;
