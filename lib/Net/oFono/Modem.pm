package Net::oFono::Modem;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::oFono::Modem

=cut

our $VERSION = '0.001';

use base qw(Net::oFono::Helpers::EventMgr);

use Net::DBus qw(:typing);

use Log::Any qw($log);

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
    my ( $class, $modem_path, %events ) = @_;

    my $self = $class->SUPER::new(%events);

    bless( $self, $class );
    $self->{modem_path} = $modem_path;

    $self->_init();
    $self->GetProperties(1);

    return $self;
}

sub _init
{
    my $self = $_[0];
    my $bus  = Net::DBus->system();
    $self->{remote_obj} =
      $bus->get_service("org.ofono")->get_object( $self->{modem_path}, "org.ofono.Modem" );

    my $on_property_changed = sub { return $self->onPropertyChanged(@_); };
    $self->{sig_property_changed} =
      $self->{remote_obj}->connect_to_signal( "PropertyChanged", $on_property_changed );

    return;
}

sub modem_path
{
    return $_[0]->{modem_path};
}

sub DESTROY
{
    my $self = $_[0];

    defined($self->{remote_obj}) and 
    $self->{remote_obj}->disconnect_from_signal( "PropertyChanged", $self->{sig_property_changed} );

    undef $self->{remote_obj};

    return;
}

sub onPropertyChanged
{
    my ( $self, $property, $value ) = @_;
    $self->{properties}->{$property} = $value;
    $self->trigger_event("ON_PROPERTY_CHANGED", $property);
    $self->trigger_event("ON_PROPERTY_" . uc($property) . "_CHANGED", $value);
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
