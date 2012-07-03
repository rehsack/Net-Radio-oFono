package Net::Radio::oFono::NetworkRegistration;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::Radio::oFono::NetworkRegistration - provide NetworkRegistration interface for Modem objects

=cut

our $VERSION = '0.001';

use Net::DBus qw(:typing);

require Net::Radio::oFono::NetworkOperator;

use Net::Radio::oFono::Roles::Manager qw(Operator);
use base qw(Net::Radio::oFono::Modem Net::Radio::oFono::Roles::Manager);

=head1 SYNOPSIS

  my $oFono = Net::Location::oFono->new();
  my @modems = Net::Location::oFono->get_modems();
  # show default network information
  foreach my $modem_path (@modems) {
    my $netreg = Net::Location::oFono->get_modem_interface($modem_path, "NetworkRegistration");
    say "Status: ", $netreg->GetProperty("Status"),
        "Name: ", $netreg->GetProperty("Name"),
        "LocationAreaCode: ", $netreg->GetProperty("LocationAreaCode"),
        "CellId: ", $netreg->GetProperty("CellId"),
        "Technology: ", $netreg->GetProperty("Technology"),
        "MobileCountryCode: ", $netreg->GetProperty("MobileCountryCode"),
        "MobileNetworkCode: ", $netreg->GetProperty("MobileNetworkCode");
  }

  # show each available network
  foreach my $modem_path (@modems) {
    my $netreg = Net::Location::oFono->get_modem_interface($modem_path, "NetworkRegistration");
    my %operators = $netreg->GetOperators();
    foreach my $oper_path (keys %operators) {
      my $oper = $netreg->GetOperator($oper_path);
      say "Status: ", $oper->GetProperty("Status"),
          "Name: ", $oper->GetProperty("Name"),
          "MobileCountryCode: ", $oper->GetProperty("MobileCountryCode"),
          "MobileNetworkCode: ", $oper->GetProperty("MobileNetworkCode"),
          "Technologies: ", join("/", $oper->GetProperty("Technologies"));
    }
  }

=head1 INHERITANCE

  Net::Radio::oFono::NetworkRegistration
  ISA Net::Radio::oFono::Modem
    ISA Net::Radio::oFono::Helpers::EventMgr
    DOES Net::Radio::oFono::Roles::RemoteObj
    DOES Net::Radio::oFono::Roles::Manager

=head1 METHODS

See C<ofono/doc/network-api.txt> for valid properties and detailed
action description and possible errors.

=head2 _init($obj_path)

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

=head2 GetOperators(;$force)

Retrieve array of operator object and properties.

This method can be used to retrieve the current operator list.  This is
either an empty list (when not registered to any network) or a list with
one or more operators (when registered).

This list will also return (by oFono) cached values of previously seen
networks.  Manual updates to list can only be done via the I<Scan()> method
call.

Set the I<$force> parameter to a true value when no D-Bus main loop
is running and signal handling might be incomplete.

Returns a hash with object paths of the operators as key and their
current properties as hash reference as value.

This method is injected by L<Net::Radio::oFono::Roles::Manager> as an alias
for L<Net::Radio::oFono::Roles::Manager/GetObjects(;$force)|GetObjects()>.

=head2 GetOperator($obj_path;$force)

Returns an instance of the specified L<Net::Radio::oFono::NetworkOperator|Operator>.

Set the I<$force> parameter to a true value when no D-Bus main loop
is running and signal handling might be incomplete.

This method is injected by L<Net::Radio::oFono::Roles::Manager> as an alias
for L<Net::Radio::oFono::Roles::Manager/GetObject($object_path;$force)|GetObject()>.

=head2 Register()

Attempts to register to the default network. The default network is
normally selected by the settings from the SIM card.

To register into another network, invoke I<Register()> on a
L<Net::Radio::oFono::NetworkOperator> instance returned via
I<GetOperators()>.

=cut

sub Register
{
    my ($self) = @_;

    $self->{remote_obj}->Register();

    return;
}

=head2 Scan()

Runs a network operator scan to discover the currently available operators.
This operation can take several seconds, and up to several minutes on some
modems.  This can be used to help the user determine what is the best
operator to use if forced to roam on a foreign network.

=cut

sub Scan
{
    my ($self) = @_;

    return $self->{remote_obj}->Scan();
}

1;
