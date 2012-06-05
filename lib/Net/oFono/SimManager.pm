package Net::oFono::SimManager;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::oFono::SimManager

=cut

our $VERSION = '0.001';

use Carp qw/croak/;
use Net::DBus;

use Data::Dumper;

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Net::oFono::Manager;

    my $oMgr = Net::oFono::Manager->new();
    my @modems = $oMgr->GetModems();
    my ($mcc, $mnc, $lac, ...) = $

=head1 METHODS

=head2 new

=cut

sub new
{
    my ($class, $modem_path) = @_;

    my $self = bless( { modem_path => $modem_path }, $class );

    $self->_init();

    return $self;
}

sub _init
{
    my $self = $_[0];
    my $bus           = Net::DBus->system();
    $self->{simmgr} = $bus->get_service("org.ofono")->get_object( $self->{modem_path}, "org.ofono.SimManager" );

    my $on_property_changed = sub { return $self->onPropertyChanged(@_); };
    $self->{sig_property_changed} = $self->{simmgr}->connect_to_signal( "PropertyChanged", $on_property_changed );

    return;
}

sub DESTROY
{
    my $self = $_[0];

    $self->{simmgr}->disconnect_from_signal( "PropertyChanged",   $self->{sig_property_changed} );

    undef $self->{simmgr};

    return $self->SUPER::DESTROY();
}

sub onPropertyChanged
{
    my ($self, $property, $value) = @_;
    $self->{properties}->{$property} = $value;
    return;
}

sub GetProperties
{
    my ( $self, $force ) = @_;

    $force and %{ $self->{properties} } = @{ $self->{simmgr}->GetProperties() };

    return wantarray ? %{ $self->{properties} } : $self->{properties};
}

sub GetProperty
{
    my ($self, $property, $force) = @_;

    $force and $self->GetProperties(1);

    return $self->{properties}->{$property};
}

my @valid_pin_types = (
    qw(none pin phone firstphone pin2 network netsub service corp puk),
    qw(firstphonepuk puk2 networkpuk netsubpuk servicepuk corppuk)
    );

sub ChangePin
{
    my ($self, $pin_type, $oldpin, $newpin) = @_;

    $pin_type ~~ @valid_pin_types or croak( "Invalid PIN type: '" . $pin_type . "'. Valid are: '" . join( "', '", @valid_pin_types ) . "'.");

    $self->{simmgr}->ChangePin( $pin_type, $oldpin, $newpin );

    return;
}

sub EnterPin
{
    my ($self, $pin_type, $pin) = @_;

    $pin_type ~~ @valid_pin_types or croak( "Invalid PIN type: '" . $pin_type . "'. Valid are: '" . join( "', '", @valid_pin_types ) . "'.");

    $self->{simmgr}->EnterPin( $pin_type, $pin );

    return;
}

sub ResetPin
{
    my ($self, $pin_type, $puk, $pin) = @_;

    $pin_type ~~ @valid_pin_types or croak( "Invalid PIN type: '" . $pin_type . "'. Valid are: '" . join( "', '", @valid_pin_types ) . "'.");

    $self->{simmgr}->ResetPin( $pin_type, $puk, $pin );

    return;
}

sub LockPin
{
    my ($self, $pin_type, $pin) = @_;

    $pin_type ~~ @valid_pin_types or croak( "Invalid PIN type: '" . $pin_type . "'. Valid are: '" . join( "', '", @valid_pin_types ) . "'.");

    $self->{simmgr}->LockPin( $pin_type, $pin );

    return;
}

sub UnlockPin
{
    my ($self, $pin_type, $pin) = @_;

    $pin_type ~~ @valid_pin_types or croak( "Invalid PIN type: '" . $pin_type . "'. Valid are: '" . join( "', '", @valid_pin_types ) . "'.");

    $self->{simmgr}->UnlockPin( $pin_type, $pin );

    return;
}

sub GetIcon
{
    my ($self, $id) = @_;

    return $self->{simmgr}->getIcon($id);
}

1;
