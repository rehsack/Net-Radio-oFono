package Net::Radio::oFono::CellBroadcast;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::Radio::oFono::CellBroadcast

=cut

our $VERSION = '0.001';

use Net::DBus qw(:typing);

use base qw(Net::Radio::oFono::Modem);

use Data::Dumper;

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Net::Radio::oFono::Manager;

    my $oMgr = Net::Radio::oFono::Manager->new();
    my @modems = $oMgr->GetModems();
    my ($mcc, $mnc, $lac, ...) = $

=head1 METHODS

=head2 new

=cut

sub _init
{
    my ($self, $obj_path) = @_;

    (my $interface = ref($self)) =~ s/Net::Radio::oFono:://;

    # initialize base class
    $self->Net::Radio::oFono::Modem::_init( $obj_path );

    my $on_incoming_broadcast = sub { return $self->onIncomingBroadcast(@_); };
    $self->{sig_incoming_broadcast} = $self->{remote_obj}->connect_to_signal( "IncomingBroadcast", $on_incoming_broadcast );

    my $on_emergency_broadcast = sub { return $self->onEmergencyBroadcast(@_); };
    $self->{sig_emergency_broadcast} = $self->{remote_obj}->connect_to_signal( "EmergencyBroadcast", $on_emergency_broadcast );

    return;
}

sub DESTROY
{
    my $self = $_[0];

    defined($self->{remote_obj}) and $self->{manager}->disconnect_from_signal( "IncomingBroadcast",   $self->{sig_incoming_broadcast} );
    defined($self->{remote_obj}) and $self->{manager}->disconnect_from_signal( "EmergencyBroadcast", $self->{sig_emergency_broadcast} );

    # initialize base class
    $self->Net::Radio::oFono::Modem::DESTROY();

    return;
}

sub onIncomingBroadcast
{
    my ( $self, $text, $topic ) = @_;
    $self->trigger_event("ON_INCOMING_BROADCAST", [$text, $topic]);
    return;
}

sub onEmergencyBroadcast
{
    my ( $self, $text, $topic ) = @_;
    $self->trigger_event("ON_EMERGENCY_BROADCAST", [$text, $topic]);
    return;
}

1;
