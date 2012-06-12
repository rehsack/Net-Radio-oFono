package Net::Radio::oFono::Manager;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::Radio::oFono::Manager - access to oFono's Manager objects

=cut

our $VERSION = '0.001';

use Net::Radio::oFono::Roles::Manager qw(Modem);    # injects GetModem(s) etc.
use base
  qw(Net::Radio::oFono::Helpers::EventMgr Net::Radio::oFono::Roles::RemoteObj Net::Radio::oFono::Roles::Manager);

use Net::DBus qw(:typing);

=head1 SYNOPSIS

Provides access to oFono's Modem Manager object (org.ofono.Manager interface).

  use Net::Radio::oFono::Manager;
  ...
  my $manager = Net::Radio::oFono::Manager->new(
    ON_MODEM_ADDED   => \&on_modem_added,
    ON_MODEM_REMOVED => \&on_modem_removed,
  );

Usually L<Net::Radio::oFono> does all of it for you, including modem
management and interface instantiation.

=head1 METHODS

=head2 new(;%events)

Instantiates new modem manager.

=cut

sub new
{
    my ( $class, %events ) = @_;

    my $self = $class->SUPER::new(%events);

    bless( $self, $class );

    $self->_init();

    return $self;
}

=head2 init()

Initialized RemoteObj and Manager roles.

=cut

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

=head2 GetModems(;$force)

Alias for L<Net::Radio::oFono::Roles::Manager/GetObjects>.

=head2 GetModem($object_path;$force)

Alias for L<Net::Radio::oFono::Roles::Manager/GetObject>.

=cut

1;
