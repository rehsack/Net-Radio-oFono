package Net::oFono::NetworkRegistration;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::oFono::NetworkRegistration

=cut

our $VERSION = '0.001';

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
    $self->{nwreg} = $bus->get_service("org.ofono")->get_object( $self->{modem_path}, "org.ofono.NetworkRegistration" );

    my $on_property_changed = sub { return $self->onPropertyChanged(@_); };
    $self->{sig_property_changed} = $self->{nwreg}->connect_to_signal( "PropertyChanged", $on_property_changed );

    return;
}

sub DESTROY
{
    my $self = $_[0];

    $self->{nwreg}->disconnect_from_signal( "PropertyChanged",   $self->{sig_property_changed} );

    undef $self->{nwreg};

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

    $force and %{ $self->{properties} } = @{ $self->{nwreg}->GetProperties() };

    return wantarray ? %{ $self->{properties} } : $self->{properties};
}

sub GetProperty
{
    my ($self, $property, $force) = @_;

    $force and $self->GetProperties(1);

    return $self->{properties}->{$property};
}

sub Register
{
    my ($self) = @_;

    $self->{nwreg}->Register();

    return;
}

sub GetOperators
{
    my ($self) = @_;

    return $self->{nwreg}->GetOperators();
}

sub Scan
{
    my ($self) = @_;

    return $self->{nwreg}->Scan();
}

1;
