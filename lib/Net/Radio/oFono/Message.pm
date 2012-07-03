package Net::Radio::oFono::Message;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::Radio::oFono::Message - provide Message API for objects managed by MessageManager

=cut

our $VERSION = '0.001';

use Net::DBus qw(:typing);

use base
  qw(Net::Radio::oFono::Helpers::EventMgr Net::Radio::oFono::Roles::RemoteObj Net::Radio::oFono::Roles::Properties);

=head1 SYNOPSIS

  my $oFono = Net::Location::oFono->new();
  my @modems = Net::Location::oFono->get_modems();
  foreach my $modem_path (@modems) {
    my $msgman = Net::Location::oFono->get_modem_interface($modem_path, "MessageManager");
    my %msgs = $msgman->GetMessages();
    foreach my $msg_path (keys %msgs) {
      my $msg = $msgman->GetMessage($msg_path);
      say "msg: ", $msg_path,
          "State: ", $msg->GetProperty("State");
    }
  }

=head1 INHERITANCE

  Net::Radio::oFono::Message
  ISA Net::Radio::oFono::Helpers::EventMgr
  DOES Net::Radio::oFono::Roles::RemoteObj
  DOES Net::Radio::oFono::Roles::Properties

=head1 METHODS

See C<ofono/doc/message-api.txt> for valid properties and detailed
action description and possible errors.

=head2 new($obj_path;%events)

Instantiates new Net::Radio::oFono::Message object at specified object path
and registers initial events to call on ...

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

Initializes the Message interface. Using the "basename" of the instantiated package
as interface name for the RemoteObj role.

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

=head2 Cancel

Cancel a message that was previously sent. Only messages that are waiting
on queue can be cancelled and it's not possible to cancel messages that
already had some parts sent.

=cut

sub Cancel
{
    my ($self) = @_;

    $self->{remote_obj}->Cancel();

    return;
}

1;

