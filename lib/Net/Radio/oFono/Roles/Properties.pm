package Net::Radio::oFono::Roles::Properties;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::Radio::oFono::Modem

=cut

our $VERSION = '0.001';

# Must be a base class of target
# use base qw(Net::Radio::oFono::Helpers::EventMgr);

use Net::DBus qw(:typing);

use Log::Any qw($log);

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
    my $self = $_[0];

    my $on_property_changed = sub { return $self->onPropertyChanged(@_); };
    $self->{sig_property_changed} =
      $self->{remote_obj}->connect_to_signal( "PropertyChanged", $on_property_changed );

    $self->GetProperties(1);

    return;
}

sub obj_path
{
    return $_[0]->{obj_path};
}

sub DESTROY
{
    my $self = $_[0];

    defined( $self->{remote_obj} )
      and $self->{remote_obj}
      ->disconnect_from_signal( "PropertyChanged", $self->{sig_property_changed} );

    return;
}

sub onPropertyChanged
{
    my ( $self, $property, $value ) = @_;
    $self->{properties}->{$property} = $value;
    $self->trigger_event( "ON_PROPERTY_CHANGED",                       $property );
    $self->trigger_event( "ON_PROPERTY_" . uc($property) . "_CHANGED", $value );
    return;
}

sub GetProperties
{
    my ( $self, $force ) = @_;

    $force and %{ $self->{properties} } = %{ $self->{remote_obj}->GetProperties() };

    return wantarray ? %{ $self->{properties} } : $self->{properties};
}

sub GetProperty
{
    my ( $self, $property, $force ) = @_;

    $force and $self->GetProperties(1);

    return $self->{properties}->{$property};
}

sub SetProperty
{
    my ( $self, $property, $value ) = @_;

    return $self->{remote_obj}->SetProperty( dbus_string($property), $value );
}

sub SetProperties
{
    my ( $self, %properties ) = @_;

    while ( my ( $property, $value ) = each(%properties) )
    {
        $self->SetProperty( $property, $value );
    }

    return;
}

1;
