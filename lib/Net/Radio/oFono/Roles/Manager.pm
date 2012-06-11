package Net::Radio::oFono::Roles::Manager;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::Radio::oFono::Roles::Manager - Role for Interfaces which manages objects

=cut

our $VERSION = '0.001';

# must be done by embedding class
# use base qw(Net::Radio::oFono::Helpers::EventMgr);

use Net::DBus qw(:typing);
use Carp qw/croak/;

use Log::Any qw($log);

use Data::Dumper;

=head1 SYNOPSIS

...

=head1 FUNCTIONS

=head2 manages_objects_of

=cut

sub import
{
    my ($pkg, $type) = @_;
    my $caller = caller;

    if( defined( $type ) && !($caller->can("Get${type}")) )
    {
	$pkg = __PACKAGE__; # avoid inheritance confusion

	my $code = <<"EOC";
package $caller;

sub Get${type}s
{
    return ${pkg}::GetObjects(\@_);
}

sub Get${type}
{
    return ${pkg}::GetObject(\@_);
}

1;
EOC
	eval $code or die "Can't inject provides-API";
    }

    return 1;
}

=head1 METHODS

=cut

sub _init
{
    my ($self, $type, $interface) = @_;

    $interface //= $type;
    $self->{mgmt_type} = $type;
    $self->{MGMT_TYPE} = uc($type);
    $self->{mgmt_interface} = $interface;

    my $on_obj_added = sub { return $self->onObjectAdded(@_); };
    $self->{sig_obj_added} = $self->{remote_obj}->connect_to_signal( "${type}Added", $on_obj_added );

    my $on_obj_removed = sub { return $self->onObjectRemoved(@_); };
    $self->{sig_obj_removed} = $self->{remote_obj}->connect_to_signal( "${type}Removed", $on_obj_removed );

    $self->GetObjects(1);

    return;
}

sub DESTROY
{
    my $self = $_[0];

    my $type = $self->{mgmt_type};
    $type or croak "Please use ogd";

    defined($self->{remote_obj}) and $self->{manager}->disconnect_from_signal( "${type}Added",   $self->{sig_obj_added} );
    defined($self->{remote_obj}) and $self->{manager}->disconnect_from_signal( "${type}Removed", $self->{sig_obj_removed} );

    undef $self->{mgmt_objects};

    return;
}

=head2 GetObjects

=cut

sub GetObjects
{
    my ( $self, $force ) = @_;

    if ($force)
    {
	my $getter = "Get" . $self->{mgmt_type} . "s";
        my @obj_lst = @{ $self->{remote_obj}->$getter() };
        my %mgmt_objects;

        foreach my $obj_info (@obj_lst)
        {
            $mgmt_objects{ $obj_info->[0] } = $obj_info->[1];
        }

        $self->{mgmt_objects} = \%mgmt_objects;
    }

    return wantarray ? %{ $self->{mgmt_objects} } : $self->{mgmt_objects};
}

=head2 GetObject

=cut

sub GetObject
{
    my ( $self, $obj_path, $force ) = @_;

    $force and $self->GetObjects($force);

    my $objClass = "Net::Radio::oFono::" . $self->{mgmt_interface};
    # check for package first, but Package::Util is just a reserved name and Module::Util is to stupid
    # probably $objClass->DOES($typical_role) is a way out, but it's not really the same ...
    return $objClass->new( $obj_path );
}

sub onObjectAdded
{
    my ( $self, $obj_path, $properties ) = @_;

    $self->{mgmt_objects}->{$obj_path} = $properties;
    $self->trigger_event("ON_" . $self->{MGMT_TYPE} . "_ADDED", $obj_path);

    return;
}

sub onObjectRemoved
{
    my ( $self, $obj_path ) = @_;

    delete $self->{mgmt_objects}->{$obj_path};
    $self->trigger_event("ON_" . $self->{MGMT_TYPE} . "_REMOVED", $obj_path);

    return;
}

1;
