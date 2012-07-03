package Net::Radio::oFono::NetworkOperator;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::Radio::oFono::NetworkOperator - provide NetworkOperator API for objects managed by NetworkRegistration

=cut

our $VERSION = '0.001';

use Net::DBus qw(:typing);

# R/O
use base
  qw(Net::Radio::oFono::Helpers::EventMgr Net::Radio::oFono::Roles::RemoteObj Net::Radio::oFono::Roles::Properties);

=head1 SYNOPSIS

  my $oFono = Net::Location::oFono->new();
  my @modems = Net::Location::oFono->get_modems();
  foreach my $modem_path (@modems) {
    my $simmgr = Net::Location::oFono->get_modem_interface($modem_path, "SimManager");
    $simmgr->GetProperty("SubscriberIdentity") eq $cfg{IMSI} # identify right one
      or next;
    my $netreg = Net::Location::oFono->get_modem_interface($modem_path, "NetworkRegistration");
    my %operators = $netreg->GetOperators();
    foreach my $oper_path (keys %operators) {
      my $oper = $netreg->GetOperator($oper_path);
      if( $oper->GetProperty("Name") =~ $pref ) {
	$oper->Register();
	last;
      }
    }
  }

=head1 DESCRIPTION

This class provide NetworkOperator API for objects managed by
L<Net::Radio::oFono::NetworkRegistration|NetworkRegistration>.

=head1 INHERITANCE

  Net::Radio::oFono::NetworkOperator
  ISA Net::Radio::oFono::Helpers::EventMgr
  DOES Net::Radio::oFono::Roles::RemoteObj
  DOES Net::Radio::oFono::Roles::Properties

=head1 METHODS

See C<ofono/doc/network-api.txt> for valid properties and detailed
action description and possible errors.

=head2 new

=cut

sub new
{
    my ( $class, $obj_path, %events ) = @_;

    my $self = $class->SUPER::new(%events);

    bless( $self, $class );

    $self->_init($obj_path);
    $self->GetProperties(1);

    return $self;
}

sub _init
{
    my ( $self, $obj_path ) = @_;

    ( my $interface = ref($self) ) =~ s/Net::Radio::oFono:://;

    # initialize roles
    $self->Net::Radio::oFono::Roles::RemoteObj::_init( $obj_path, "org.ofono.$interface" );
    $self->Net::Radio::oFono::Roles::Properties::_init();

    return;
}

sub DESTROY
{
    my $self = $_[0];

    # destroy roles
    $self->Net::Radio::oFono::Roles::Properties::DESTROY();
    $self->Net::Radio::oFono::Roles::RemoteObj::DESTROY();

    # destroy base class
    $self->Net::Radio::oFono::Helpers::EventMgr::DESTROY();

    return;
}

=head2 Register()

Attempts to register to this network operator.

The method will return immediately, the result should be observed by
tracking the NetworkRegistration Status property.

=cut

sub Register
{
    my ($self) = @_;

    $self->{remote_obj}->Register();

    return;
}

1;
