package Net::Radio::oFono::Roles::RemoteObj;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::Radio::oFono::Roles::RemoteObj

=cut

our $VERSION = '0.001';

# Must be a base class of target
# use base qw(Net::Radio::oFono::Helpers::EventMgr);

use Net::DBus qw(:typing);

use Log::Any qw($log);

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
    my ( $self, $obj_path, $iface ) = @_;

    my $bus = Net::DBus->system();

    $self->{obj_path} = $obj_path;
    $self->{remote_obj} = $bus->get_service("org.ofono")->get_object( $obj_path, $iface );

    return;
}

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
