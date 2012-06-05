package Net::oFono::Modem;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::oFono::Modem

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
    $self->{modem} = $bus->get_service("org.ofono")->get_object( $self->{modem_path}, "org.ofono.Modem" );

    my $on_property_changed = sub { return $self->onPropertyChanged(@_); };
    $self->{sig_property_changed} = $self->{modem}->connect_to_signal( "PropertyChanged", $on_property_changed );

    return;
}

sub DESTROY
{
    my $self = $_[0];

    $self->{modem}->disconnect_from_signal( "PropertyChanged",   $self->{sig_property_changed} );

    undef $self->{modem};

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

    $force and %{ $self->{properties} } = @{ $self->{modem}->GetProperties() };

    return wantarray ? %{ $self->{properties} } : $self->{properties};
}

sub GetProperty
{
    my ($self, $property, $force) = @_;

    $force and $self->GetProperties(1);

    return $self->{properties}->{$property};
}

sub SetProperty
{
    my ($self, $property, $value);

    return $self->{modem}->SetProperty($property, $value);
}

sub SetProperties
{
    my ($self, %properties) = @_;

    while( my ($property, $value) = each(%properties) )
    {
	$self->SetProperty($property, $value);
    }

    return;
}

1;
