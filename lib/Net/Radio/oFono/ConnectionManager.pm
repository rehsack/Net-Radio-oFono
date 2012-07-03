package Net::Radio::oFono::ConnectionManager;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::Radio::oFono::ConnectionManager - provide ConnectionManager interface for Modem objects

=cut

our $VERSION = '0.001';

use Net::DBus qw(:typing);

require Net::Radio::oFono::ConnectionContext;

use Net::Radio::oFono::Roles::Manager qw(Context);
use base qw(Net::Radio::oFono::Modem Net::Radio::oFono::Roles::Manager);

=head1 SYNOPSIS

  my $oFono = Net::Location::oFono->new();
  my @modems = Net::Location::oFono->get_modems();
  # show default network information
  foreach my $modem_path (@modems) {
    my $conman = Net::Location::oFono->get_modem_interface($modem_path, "ConnectionManager");
    say "Attached: ", 0+$conman->GetProperty("Attached"), # boolean
        "Bearer: ", $conman->GetProperty("Bearer"),
        "RoamingAllowed: ", 0+$conman->GetProperty("RoamingAllowed"); # boolean
    $conman->DeactivateAll(); # end of data
  }

=head1 INHERITANCE

  Net::Radio::oFono::ConnectionManager
  ISA Net::Radio::oFono::Modem
    ISA Net::Radio::oFono::Helpers::EventMgr
    DOES Net::Radio::oFono::Roles::RemoteObj
    DOES Net::Radio::oFono::Roles::Manager

=head1 METHODS

See C<ofono/doc/conman-api.txt> for valid properties and detailed
action description and possible errors.

=head2 _init($obj_path)

Initializes the modem and the manager role to handle the
I<ContextAdded> and I<ContextRemoved> signals.

=cut

sub _init
{
    my ( $self, $obj_path ) = @_;

    ( my $interface = ref($self) ) =~ s/Net::Radio::oFono:://;

    # initialize base class
    $self->Net::Radio::oFono::Modem::_init($obj_path);
    # initialize role
    $self->Net::Radio::oFono::Roles::Manager::_init( "Context", "ConnectionContext" );

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

=head2 GetContexts(;$force)

Get hash of context objects and properties.

Set the I<$force> parameter to a true value when no D-Bus main loop
is running and signal handling might be incomplete.

This method is injected by L<Net::Radio::oFono::Roles::Manager> as an alias
for L<Net::Radio::oFono::Roles::Manager/GetObjects(;$force)|GetObjects()>.

=head2 GetContext($obj_path;$force)

Returns an instance of the specified L<Net::Radio::oFono::ConnectionContext|Context>.

Set the I<$force> parameter to a true value when no D-Bus main loop
is running and signal handling might be incomplete.

This method is injected by L<Net::Radio::oFono::Roles::Manager> as an alias
for L<Net::Radio::oFono::Roles::Manager/GetObject($object_path;$force)|GetObject()>.

=head2 DeactivateAll()

Deactivates all active contexts.

=cut

sub DeactivateAll
{
    my $self = $_[0];

    $self->{remote_obj}->DeactivateAll();

    return;
}

=head2 AddContext($type)

Creates a new Primary context.  The type contains the intended purpose of
the context.

=cut

sub AddContext
{
    my ( $self, $type ) = @_;

    return $self->{remote_obj}->AddContext( dbus_string($type) );
}

=head2 RemoveContext($obj_path)

Removes a primary context.  All secondary contexts, if any, associated with
the primary context are also removed.

=cut

sub RemoveContext
{
    my ( $self, $obj_path ) = @_;

    $self->{remote_obj}->RemoveContext( dbus_object_path($obj_path) );

    return;
}

#sub RemoveAllContexts
#{
#    my ( $self ) = @_;
#
#    my @context_obj_paths = keys %{$self->{contexts}};
#    foreach my $cop (@context_obj_paths)
#    {
#	$self->{remote_obj}->RemoveContext( dbus_object_path($cop) );
#    }
#
#    return;
#}

1;
