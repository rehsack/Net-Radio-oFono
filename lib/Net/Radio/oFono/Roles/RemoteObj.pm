package Net::Radio::oFono::Roles::RemoteObj;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::Radio::oFono::Roles::RemoteObj - lifecycle management for remote oFono objects

=head1 DESCRIPTION

This package provides a role for being added to classes which need to access
remote dbus objects of oFono.

=cut

our $VERSION = '0.001';

# Must be a base class of target
# use base qw(Net::Radio::oFono::Helpers::EventMgr);

use Net::DBus qw(:typing);

use Log::Any qw($log);

=head1 SYNOPSIS

Provides remote object lifecycle control for oFono objects/interfaces.

    package Net::Radio::oFono::NewInterface;

    use base qw(Net::Radio::oFono::Helpers::EventMgr? Net::Radio::oFono::Roles::RemoteObj ...);

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
	...

	return;
    }

    sub DESTROY
    {
	my $self = $_[0];

	# destroy roles
	...
	$self->Net::Radio::oFono::Roles::RemoteObj::DESTROY(); # must be last one

	# destroy base class
	$self->Net::Radio::oFono::Helpers::EventMgr::DESTROY();

	return;
    }

=head1 METHODS

=head2 _init

Called to initialize the object. Expects remote object path and interface
name (like L<Net::DBus::RemoteObject>).

=cut

sub _init
{
    my ( $self, $obj_path, $iface ) = @_;

    my $bus = Net::DBus->system();

    $self->{obj_path} = $obj_path;
    $self->{remote_obj} = $bus->get_service("org.ofono")->get_object( $obj_path, $iface );

    return;
}

=head2 obj_path

Returns the DBus object path of the managed remote object

=cut

sub obj_path
{
    return $_[0]->{obj_path};
}

sub DESTROY
{
    my $self = $_[0];

    undef $self->{remote_obj};
    undef $self->{obj_path};

    return;
}

1;
