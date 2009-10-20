package DBIx::Connector::Driver;

use strict;
use warnings;
our $VERSION = '0.20';

DRIVERS: {
    my %DRIVERS;

    sub new {
        my ($class, $driver) = @_;
        return $DRIVERS{$driver} ||= do {
            my $subclass = __PACKAGE__ . "::$driver";
            eval "require $subclass";
            $class = $subclass unless $@;
            bless { driver => $driver } => $class;
        };
    }
}

sub ping {
    my ($self, $dbh) = @_;
    $dbh->ping;
}

sub begin_work {
    my ($self, $dbh) = @_;
    $dbh->begin_work;
}

sub commit {
    my ($self, $dbh) = @_;
    $dbh->commit;
}

sub rollback {
    my ($self, $dbh) = @_;
    $dbh->rollback;
}

sub savepoint {
    my ($self, $dbh, $name) = @_;
    die "The $self->{driver} driver does not support savepoints";
}

sub release {
    my ($self, $dbh, $name) = @_;
    die "The $self->{driver} driver does not support savepoints";
}

sub rollback_to {
    my ($self, $dbh, $name) = @_;
    die "The $self->{driver} driver does not support savepoints";
}

1;
__END__

=head1 Name

DBIx::Connector::Driver - Database-specific connection interface

=head1 Description

Some of the things that DBIx::Connector does are implemented differently by
different drivers, or the official interface provided by the DBI may not be
implemented for a particular driver. The driver-specific code therefore is
encapsulated in this separate driver class.

Most of the DBI drivers work uniformly, so in most cases the implementation
provided here in DBIx::Connector::Driver will work just fine. It's only when
something is different that a driver subclass needs to be added. In such a
case, the subclass's name is the same as the DBI driver. For example the
driver for DBD::Pg is
L<DBIx::Connector::Driver::Pg|DBIx::Connector::Driver::Pg> and the driver
for DBD::mysql is
L<DBIx::Connector::Driver::mysql|DBIx::Connector::Driver::mysql>.

If you're just a user of DBIx::Connector, you can ignore the driver classes.
DBIx::Connector uses them internally to do its magic, so you needn't worry
about them.

=head1 Interface

In case you need to implement a driver, here's the interface you can modify.

=head2 Constructor

=head3 C<new>

  my $driver = DBIx::Connector::Driver->new( $driver );

Constructs and returns a driver object. Each driver class is implemented as a
singleton, so the same driver object is always returned for the same driver.
The C<driver> parameter should be a Perl DBI driver name, such as C<Pg> for
L<DBD::Pg|DBD::Pg> or C<SQLite> for L<DBD::SQLite|DBD::SQLite>. If a subclass
has been defined for C<$driver>, then the object will be of that class.
Otherwise it will be an instance of the driver base class.

=head2 Instance Methods

=head3 C<ping>

  $driver->ping($dbh);

Calls C<< $dbh->ping >>. Override if for some reason the DBI driver doesn't do
it right.

=head3 C<begin_work>

  $driver->begin_work($dbh);

Calls C<< $dbh->begin_work >>. Override if for some reason the DBI driver
doesn't do it right.

=head3 C<commit>

  $driver->commit($dbh);

Calls C<< $dbh->commit >>. Override if for some reason the DBI driver doesn't
do it right.

=head3 C<rollback>

  $driver->rollback($dbh);

Calls C<< $dbh->rollback >>. Override if for some reason the DBI driver
doesn't do it right.

=head3 C<savepoint>

  $driver->savepoint($dbh, $name);

Dies with the message C<"The $driver driver does not support savepoints">.
Override if your database does in fact support savepoints. The driver subclass
should create a savepoint with the given C<$name>. See the implementation in
L<DBIx::Connector::Driver::Pg|DBIx::Connector::Driver::Pg> and
L<DBIx::Connector::Driver::Oracle|DBIx::Connector::Driver::Oracle> for
examples.

=head3 C<release>

  $driver->release($dbh, $name);

Dies with the message C<"The $driver driver does not support savepoints">.
Override if your database does in fact support savepoints. The driver subclass
should release the savepoint with the given C<$name>. See the implementation
in L<DBIx::Connector::Driver::Pg|DBIx::Connector::Driver::Pg> and
L<DBIx::Connector::Driver::Oracle|DBIx::Connector::Driver::Oracle> for
examples.

=head3 C<rollback_to>

  $driver->rollback_to($dbh, $name);

Dies with the message C<"The $driver driver does not support savepoints">.
Override if your database does in fact support savepoints. The driver subclass
should rollback to the savepoint with the given C<$name>. See the
implementation in L<DBIx::Connector::Driver::Pg|DBIx::Connector::Driver::Pg>
and L<DBIx::Connector::Driver::Oracle|DBIx::Connector::Driver::Oracle> for
examples.

=head1 Authors

This module was written and is maintained by:

=over

=item David E. Wheeler <david@kineticode.com>

=back

It is based on code written by:

=over

=item Matt S. Trout <mst@shadowcatsystems.co.uk>

=item Peter Rabbitson <rabbit+dbic@rabbit.us>

=back

=head1 Copyright and License

Copyright (c) 2009 David E. Wheeler. Some Rights Reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
