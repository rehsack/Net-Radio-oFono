package Net::Radio::oFono;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::Radio::oFono - Perl API to oFono

=cut

our $VERSION = '0.001';

use Net::Radio::oFono::Manager;
use Net::Radio::oFono::Modem;
use Net::Radio::oFono::SimManager;
use Net::Radio::oFono::RadioSettings;
use Net::Radio::oFono::NetworkRegistration;
use Net::Radio::oFono::ConnectionManager;
use Net::Radio::oFono::MessageManager;
use Net::Radio::oFono::MessageWaiting;
use Net::Radio::oFono::CellBroadcast;

use Log::Any qw($log);

use base qw(Net::Radio::oFono::Helpers::EventMgr);

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Net::Radio::oFono;

    my $oFono = Net::Radio::oFono->new();
    my @modems = $oFono->getModems();
    my ($mcc, $mnc, $lac, ...) = $

=head1 SUBROUTINES/METHODS

=head2 new

=cut

sub new
{
    my ( $class, %events ) = @_;

    my $self = __PACKAGE__->SUPER::new(%events);
    bless( $self, __PACKAGE__ );
    $self->_init();

    return $self;
}

=head2 _init

=cut

sub _init
{
    my $self = shift;

    $self->{manager} = Net::Radio::oFono::Manager->new();

    my %modems = $self->{manager}->GetModems();
    $self->{modems} = {};
    foreach my $modem_path ( keys %modems )
    {
        $self->_add_modem($modem_path);
    }

    $self->{manager}->add_event( "ON_MODEM_ADDED",   \&on_modem_added,   $self );
    $self->{manager}->add_event( "ON_MODEM_REMOVED", \&on_modem_removed, $self );

    return $self;
}

sub DESTROY
{
    my $self = $_[0];

    delete $self->{modems};
    delete $self->{manager};

    return;
}

sub _add_modem
{
    my ( $self, $modem_path ) = @_;

    my $modem = Net::Radio::oFono::Modem->new($modem_path);
    $self->{modems}->{$modem_path}->{Modem} = $modem;

    $modem->add_event( "ON_PROPERTY_CHANGED",            \&on_modem_property_changed,   $self );
    $modem->add_event( "ON_PROPERTY_INTERFACES_CHANGED", \&on_modem_interfaces_changed, $self );

    $self->_update_modem_interfaces($modem);

    $self->trigger_event( "ON_MODEM_ADDED", $modem_path );
}

sub _update_modem_interfaces
{
    my ( $self, $modem, $interfaces ) = @_;
    $interfaces //= $modem->GetProperty("Interfaces");
    my @interface_list          = map { $_ =~ s/org.ofono.//; $_ } @$interfaces;
    my $if_instances            = $self->{modems}->{ $modem->modem_path() };
    my %superflous_if_instances = map { $_ => 1 } keys %$if_instances;
    delete $superflous_if_instances{Modem};

    foreach my $interface (@interface_list)
    {
        my $if_class = "Net::Radio::oFono::$interface";
        $if_class->isa("Net::Radio::oFono::Modem") or next;
        defined( $if_instances->{$interface} ) and next;
        $if_instances->{$interface} = $if_class->new( $modem->modem_path() );
        $if_instances->{$interface}
          ->add_event( "ON_PROPERTY_CHANGED", \&on_modem_property_changed, $self );
        delete $superflous_if_instances{$interface};
        $self->trigger_event( "ON_MODEM_INTERFACE_ADDED", [ $modem->modem_path(), $interface ] );
        $self->trigger_event( "ON_MODEM_INTERFACE_" . uc($interface) . "_ADDED",
                              $modem->modem_path() );
    }

    foreach my $interface ( keys %superflous_if_instances )
    {
        delete $if_instances->{$interface};
        $self->trigger_event( "ON_MODEM_INTERFACE_REMOVED", [ $modem->modem_path(), $interface ] );
    }

    return;
}

sub get_modems
{
    my $self = $_[0];

    return keys %{ $self->{modems} };
}

sub get_modem_interface
{
    my ( $self, $modem_path, $if_name ) = @_;
    defined( $self->{modems}->{$modem_path} )
      and defined( $self->{modems}->{$modem_path}->{$if_name} )
      and return $self->{modems}->{$modem_path}->{$if_name};
    return;
}

=head2 on_modem_added

=cut

sub on_modem_added
{
    my ( $self, $manager, $event, $modem_path ) = @_;

    $self->_add_modem($modem_path);

    return;
}

=head2 on_modem_removed

=cut

sub on_modem_removed
{
    my ( $self, $manager, $event, $modem_path ) = @_;

    delete $self->{modems}->{$modem_path};
}

sub on_modem_interfaces_changed
{
    my ( $self, $modem, $event_name, $interfaces ) = @_;

    $self->_update_modem_interfaces( $modem, $interfaces );

    return;
}

sub on_modem_property_changed
{
    my ( $self, $obj, $event_name, $property ) = @_;
    my $modem_path = $obj->modem_path();
    ( my $if_name = ref($obj) ) =~ s/.*://;

    $self->trigger_event( "ON_" . uc($if_name) . "_PROPERTY_CHANGED", [ $modem_path, $property ] );
    $self->trigger_event( "ON_" . uc($if_name) . "_PROPERTY_" . uc($property) . "_CHANGED",
                          [ $modem_path, $obj->GetProperty($property) ] );

    return;
}

=head1 AUTHOR

Jens Rehsack, C<< <rehsack at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-radio-ofono at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-Radio-oFono>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::Radio::oFono

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-Radio-oFono>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-Radio-oFono>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net-Radio-oFono>

=item * Search CPAN

L<http://search.cpan.org/dist/Net-Radio-oFono/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Jens Rehsack.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;    # End of Net::Radio::oFono
