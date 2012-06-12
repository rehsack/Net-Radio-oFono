package Net::Radio::oFono::MessageManager;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::Radio::oFono::MessageManager

=cut

use Net::DBus qw(:typing);

require Net::Radio::oFono::Message;

use Net::Radio::oFono::Roles::Manager qw(Message);
use base qw(Net::Radio::oFono::Modem Net::Radio::oFono::Roles::Manager);

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
    my ( $self, $obj_path ) = @_;

    ( my $interface = ref($self) ) =~ s/Net::Radio::oFono:://;

    # initialize base class
    $self->Net::Radio::oFono::Modem::_init($obj_path);
    # initialize role
    $self->Net::Radio::oFono::Roles::Manager::_init("Message");

    my $on_incoming_message = sub { return $self->onIncomingMessage(@_); };
    $self->{sig_incoming_message} =
      $self->{remote_obj}->connect_to_signal( "IncomingMessage", $on_incoming_message );

    my $on_immediate_message = sub { return $self->onImmediateMessage(@_); };
    $self->{sig_immediate_message} =
      $self->{remote_obj}->connect_to_signal( "ImmediateMessage", $on_immediate_message );

    return;
}

sub DESTROY
{
    my $self = $_[0];

    defined( $self->{remote_obj} )
      and
      $self->{manager}->disconnect_from_signal( "IncomingMessage", $self->{sig_incoming_message} );
    defined( $self->{remote_obj} )
      and $self->{manager}
      ->disconnect_from_signal( "ImmediateMessage", $self->{sig_immediate_message} );

    # destroy role
    $self->Net::Radio::oFono::Roles::Manager::DESTROY();
    # initialize base class
    $self->Net::Radio::oFono::Modem::DESTROY();

    return;
}

sub SendMessage
{
    my ( $self, $to, $text ) = @_;

    $self->{remote_obj}->SendMessage( dbus_string($to), dbus_string($text) );

    return;
}

sub onImmediateMessage
{
    my ( $self, $message, $info ) = @_;

    $self->trigger_event( "ON_IMMEDIATE_MESSAGE", [ $message, $info ] );

    return;
}

sub onIncomingMessage
{
    my ( $self, $message, $info ) = @_;

    $self->trigger_event( "ON_INCOMING_MESSAGE", [ $message, $info ] );

    return;
}

1;
