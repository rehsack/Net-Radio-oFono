package Net::Radio::oFono::ConnectionContext;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::Radio::oFono::ConnectionContext - provide ConnectionContext API for objects managed by ConnectionManager

=cut

our $VERSION = '0.001';

use Net::DBus qw(:typing);

# R/W
use base
  qw(Net::Radio::oFono::Helpers::EventMgr Net::Radio::oFono::Roles::RemoteObj Net::Radio::oFono::Roles::Properties);

=head1 SYNOPSIS

  my $oFono = Net::Location::oFono->new();
  my @modems = Net::Location::oFono->get_modems();
  # show each available context
  foreach my $modem_path (@modems) {
    my $conman = Net::Location::oFono->get_modem_interface($modem_path, "ConnectionManager");
    my %ctxs = $conman->GetContexts();
    foreach my $ctx_path (keys %ctxs) {
      my $ctx = $conman->GetContext($ctx_path);
      say "Status: ", $ctx->GetProperty("Status"),
          "Name: ", $ctx->GetProperty("Name"),
          "Settings: ", Dumper($ctx->GetProperty("Settings") // {}), # hash
          "IPv6.Settings: ", Dumper($ctx->GetProperty("IPv6.Settings") // {}); # hash
    }
  }

=head1 METHODS

See C<ofono/doc/conman-api.txt> for valid properties and detailed
action description and possible errors.

=head2 new($obj_path;%events)

Instantiates new Net::Radio::oFono::ConnectionContext object at specified
object path and registers initial events to call on ...

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

=head2 _init($obj_path)

Initializes the ConnectionContext interface. Using the "basename" of the
instantiated package as interface name for the RemoteObj role.

=cut

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

1;
