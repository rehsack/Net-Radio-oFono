package Net::Radio::oFono::CellBroadcast;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::Radio::oFono::CellBroadcast - access Modem object's CellBroadcast interface

=cut

our $VERSION = '0.001';

use Net::DBus qw(:typing);

use base qw(Net::Radio::oFono::Modem);

=head1 SYNOPSIS

  my $oFono = Net::Location::oFono->new();
  my @modems = Net::Location::oFono->get_modems();
  foreach my $modem_path (@modems) {
    my $cellbc = Net::Location::oFono->get_modem_interface($modem_path, "CellBroadcast");
    say "Powered: ", $cellbc->GetProperty("Powered"),
        "Topics: ", $cellbc->GetProperty("Topics");
  }

=head1 INHERITANCE

  Net::Radio::oFono::CellBroadcast
  ISA Net::Radio::oFono::Modem
    ISA Net::Radio::oFono::Helpers::EventMgr
    DOES Net::Radio::oFono::Roles::RemoteObj
    DOES Net::Radio::oFono::Roles::Properties

=head1 METHODS

See C<ofono/doc/cell-broadcast-api.txt> for valid properties and detailed
action description and possible errors.

=head2 _init($obj_path)

Connects on D-Bus signals I<IncomingBroadcast> and I<EmergencyBroadcast> after
base class is initialized.

=cut

sub _init
{
    my ( $self, $obj_path ) = @_;

    ( my $interface = ref($self) ) =~ s/Net::Radio::oFono:://;

    # initialize base class
    $self->Net::Radio::oFono::Modem::_init($obj_path);

    my $on_incoming_broadcast = sub { return $self->onIncomingBroadcast(@_); };
    $self->{sig_incoming_broadcast} =
      $self->{remote_obj}->connect_to_signal( "IncomingBroadcast", $on_incoming_broadcast );

    my $on_emergency_broadcast = sub { return $self->onEmergencyBroadcast(@_); };
    $self->{sig_emergency_broadcast} =
      $self->{remote_obj}->connect_to_signal( "EmergencyBroadcast", $on_emergency_broadcast );

    return;
}

sub DESTROY
{
    my $self = $_[0];

    defined( $self->{remote_obj} )
      and $self->{remote_obj}->disconnect_from_signal( "IncomingBroadcast", $self->{sig_incoming_broadcast} );
    defined( $self->{remote_obj} )
      and $self->{remote_obj}->disconnect_from_signal( "EmergencyBroadcast", $self->{sig_emergency_broadcast} );

    # initialize base class
    $self->Net::Radio::oFono::Modem::DESTROY();

    return;
}

=head2 onIncomingBroadcast

Called when D-Bus signal I<IncomingBroadcast> is received.

Generates event C<ON_INCOMING_BROADCAST> with arguments C<< $text, $topic >>.

=cut

sub onIncomingBroadcast
{
    my ( $self, $text, $topic ) = @_;
    $self->trigger_event( "ON_INCOMING_BROADCAST", [ $text, $topic ] );
    return;
}

=head2 onEmergencyBroadcast

Called when D-Bus signal I<EmergencyBroadcast> is received.

Generates event C<ON_EMERGENCY_BROADCAST> with arguments C<< $text, $topic >>.

=cut

sub onEmergencyBroadcast
{
    my ( $self, $text, $topic ) = @_;
    $self->trigger_event( "ON_EMERGENCY_BROADCAST", [ $text, $topic ] );
    return;
}

1;
