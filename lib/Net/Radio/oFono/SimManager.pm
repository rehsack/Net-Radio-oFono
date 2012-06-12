package Net::Radio::oFono::SimManager;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::Radio::oFono::SimManager

=cut

our $VERSION = '0.001';

use Carp qw/croak/;
use Net::DBus qw(:typing);

use base qw(Net::Radio::oFono::Modem);

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

my @valid_pin_types = (
                        qw(none pin phone firstphone pin2 network netsub service corp puk),
                        qw(firstphonepuk puk2 networkpuk netsubpuk servicepuk corppuk)
                      );

sub ChangePin
{
    my ( $self, $pin_type, $oldpin, $newpin ) = @_;

    $pin_type ~~ @valid_pin_types
      or croak(   "Invalid PIN type: '"
                . $pin_type
                . "'. Valid are: '"
                . join( "', '", @valid_pin_types )
                . "'." );

    $self->{remote_obj}
      ->ChangePin( dbus_string($pin_type), dbus_string($oldpin), dbus_string($newpin) );

    return;
}

sub EnterPin
{
    my ( $self, $pin_type, $pin ) = @_;

    $pin_type ~~ @valid_pin_types
      or croak(   "Invalid PIN type: '"
                . $pin_type
                . "'. Valid are: '"
                . join( "', '", @valid_pin_types )
                . "'." );

    $self->{remote_obj}->EnterPin( dbus_string($pin_type), dbus_string($pin) );

    return;
}

sub ResetPin
{
    my ( $self, $pin_type, $puk, $pin ) = @_;

    $pin_type ~~ @valid_pin_types
      or croak(   "Invalid PIN type: '"
                . $pin_type
                . "'. Valid are: '"
                . join( "', '", @valid_pin_types )
                . "'." );

    $self->{remote_obj}->ResetPin( dbus_string($pin_type), dbus_string($puk), dbus_string($pin) );

    return;
}

sub LockPin
{
    my ( $self, $pin_type, $pin ) = @_;

    $pin_type ~~ @valid_pin_types
      or croak(   "Invalid PIN type: '"
                . $pin_type
                . "'. Valid are: '"
                . join( "', '", @valid_pin_types )
                . "'." );

    $self->{remote_obj}->LockPin( dbus_string($pin_type), dbus_string($pin) );

    return;
}

sub UnlockPin
{
    my ( $self, $pin_type, $pin ) = @_;

    $pin_type ~~ @valid_pin_types
      or croak(   "Invalid PIN type: '"
                . $pin_type
                . "'. Valid are: '"
                . join( "', '", @valid_pin_types )
                . "'." );

    $self->{remote_obj}->UnlockPin( dbus_string($pin_type), dbus_string($pin) );

    return;
}

sub GetIcon
{
    my ( $self, $id ) = @_;

    return $self->{remote_obj}->getIcon($id);
}

1;
