package Net::Radio::oFono::Manager;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::Radio::oFono::Manager - Perl API to oFono's Modem Manager

=cut

our $VERSION = '0.001';

use Net::Radio::oFono::Roles::Manager qw(Modem);    # injects GetModem(s) etc.
use base
  qw(Net::Radio::oFono::Helpers::EventMgr Net::Radio::oFono::Roles::RemoteObj Net::Radio::oFono::Roles::Manager);

use Net::DBus qw(:typing);

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

sub new
{
    my ( $class, %events ) = @_;

    my $self = $class->SUPER::new(%events);

    bless( $self, $class );

    $self->_init();

    return $self;
}

sub _init
{
    my $self = $_[0];

    # initialize roles
    $self->Net::Radio::oFono::Roles::RemoteObj::_init( "/", "org.ofono.Manager" );
    $self->Net::Radio::oFono::Roles::Manager::_init("Modem");

    return;
}

sub DESTROY
{
    my $self = $_[0];

    # destroy roles
    $self->Net::Radio::oFono::Roles::Manager::DESTROY();
    $self->Net::Radio::oFono::Roles::RemoteObj::DESTROY();

    # destroy base class
    $self->Net::Radio::oFono::Helpers::EventMgr::DESTROY();

    return;
}

=head2 GetModems

=head2 GetModem

=cut

1;
