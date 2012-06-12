package Net::Radio::oFono::ConnectionManager;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::Radio::oFono::ConnectionManager

=cut

our $VERSION = '0.001';

use Net::DBus qw(:typing);

require Net::Radio::oFono::ConnectionContext;

use Net::Radio::oFono::Roles::Manager qw(Context);
use base qw(Net::Radio::oFono::Modem Net::Radio::oFono::Roles::Manager);

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

sub DeactivateAll
{
    my $self = $_[0];

    $self->{remote_obj}->DeactivateAll();

    return;
}

sub AddContext
{
    my ( $self, $type ) = @_;

    return $self->{remote_obj}->AddContext( dbus_string($type) );
}

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
