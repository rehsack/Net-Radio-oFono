package Net::Radio::oFono::NetworkRegistration;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::Radio::oFono::NetworkRegistration

=cut

our $VERSION = '0.001';

use Net::DBus qw(:typing);

require Net::Radio::oFono::NetworkOperator;

use Net::Radio::oFono::Roles::Manager qw(Operator);
use base qw(Net::Radio::oFono::Modem Net::Radio::oFono::Roles::Manager);

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Net::Radio::oFono::Manager;

    my $oMgr = Net::Radio::oFono::Manager->new();
    my @modems = $oMgr->GetModems();
    my ($mcc, $mnc, $lac, ...) = $

=head1 METHODS

=cut

sub _init
{
    my ( $self, $obj_path ) = @_;

    ( my $interface = ref($self) ) =~ s/Net::Radio::oFono:://;

    # initialize base class
    $self->Net::Radio::oFono::Modem::_init($obj_path);
    # initialize role
    $self->Net::Radio::oFono::Roles::Manager::_init( "Operator", "NetworkOperator" );

    return;
}

sub DESTROY
{
    my $self = $_[0];

    # destroy role
    $self->Net::Radio::oFono::Roles::Manager::DESTROY();
    # initialize base class
    $self->Net::Radio::oFono::Modem::DESTROY();

    return;
}

sub Register
{
    my ($self) = @_;

    $self->{remote_obj}->Register();

    return;
}

sub Scan
{
    my ($self) = @_;

    return $self->{remote_obj}->Scan();
}

1;
