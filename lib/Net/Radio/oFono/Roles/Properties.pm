package Net::Radio::oFono::Roles::Properties;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::Radio::oFono::Roles::Properties - generic property access for remote oFono objects

=head1 DESCRIPTION

This package provides a role for being added to classes which need to access
properties of remote dbus objects of oFono. Currently no separate role for
read-only access is available.

=cut

our $VERSION = '0.001';

# Must be a base class of target
# use base qw(Net::Radio::oFono::Helpers::EventMgr);

use Net::DBus qw(:typing);

use Log::Any qw($log);

=head1 SYNOPSIS

    package Net::Radio::oFono::NewInterface;

    use base qw(Net::Radio::oFono::Helpers::EventMgr? Net::Radio::oFono::Roles::RemoteObj Net::Radio::oFono::Roles::Properties ...);

    use Net::DBus qw(:typing);

    sub new
    {
	my ( $class, %events ) = @_;

	my $self = $class->SUPER::new(%events); # SUPER::new finds first - so EventMgr::new

	bless( $self, $class );

	$self->_init();

	return $self;
    }

    sub _init
    {
	my $self = $_[0];

	# initialize roles
	$self->Net::Radio::oFono::Roles::RemoteObj::_init( "/modem_0", "org.ofono.NewInterface" ); # must be first one
	$self->Net::Radio::oFono::Roles::Properties::_init();
	...

	return;
    }

    sub DESTROY
    {
	my $self = $_[0];

	# destroy roles
	...
	$self->Net::Radio::oFono::Roles::Properties::DESTROY(); # must be last one
	$self->Net::Radio::oFono::Roles::RemoteObj::DESTROY(); # must be last one

	# destroy base class
	$self->Net::Radio::oFono::Helpers::EventMgr::DESTROY();

	return;
    }

=head1 EVENTS

Following events are triggered by this role:

=over 4

=item ON_PROPERTY_CHANGED

Triggered when a property has been changed. Submits the name of the
changed property to the listener.

=item ON_PEROPERTY_ . uc($property_name) . _CHANGED

Triggered when a property has been changed. Submits the value of the
changed property to the listener.

=back

=head1 METHODS

=head2 _init

Initializes the properties api (connects to PropertyChanged signal of remote object).

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

sub DESTROY
{
    my $self = $_[0];

    defined( $self->{remote_obj} )
      and $self->{remote_obj}
      ->disconnect_from_signal( "PropertyChanged", $self->{sig_property_changed} );

    return;
}

=head2 onPropertyChanged

Callback method used when the signal C<PropertyChanged> is received.
Can be overwritten to implement other or enhanced behavior.

=over 4

=item *

Updates properties cache

=item *

Triggers signals on property change

=back

=cut

sub onPropertyChanged
{
    my ( $self, $property, $value ) = @_;
    $self->{properties}->{$property} = $value;
    $self->trigger_event( "ON_PROPERTY_CHANGED",                       $property );
    $self->trigger_event( "ON_PROPERTY_" . uc($property) . "_CHANGED", $value );
    return;
}

=head2 GetProperties(;$force)

Returns the properties of the remote object.

When invoked with a true value as first argument, the properties are
refreshed from the remote object.

Returns the properties hash in array more and the reference to the
properties hash in scalar mode.

=over 8

=item B<TODO>

Return cloned properties to avoid dirtying the local cache ...

=back

=cut

sub GetProperties
{
    my ( $self, $force ) = @_;

    $force and %{ $self->{properties} } = %{ $self->{remote_obj}->GetProperties() };

    return wantarray ? %{ $self->{properties} } : $self->{properties};
}

=head2 GetProperty($property_name;$force)

Returns the requested property of the remote object.

When invoked with a true value as second argument, the properties are
refreshed from the remote object.

=cut

sub GetProperty
{
    my ( $self, $property, $force ) = @_;

    $force and $self->GetProperties(1);

    return $self->{properties}->{$property};
}

=head2 SetProperty($property_name,$new_value)

Sets the specified property of the remote object to the specified value.
Note that some values needs special encapsulation using dbus_I<type>().
The property name is automatically encapsulated using C<dbus_string>.

See the appropriate interface documentation in oFono to learn the
types to use.

=cut

sub SetProperty
{
    my ( $self, $property, $value ) = @_;

    return $self->{remote_obj}->SetProperty( dbus_string($property), $value );
}

=head2 SetProperties(%property_hash)

Sets all specified properties using L</SetProperty>.

=cut

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
