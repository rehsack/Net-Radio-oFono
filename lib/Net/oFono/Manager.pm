package Net::oFono::Manager;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::oFono::Manager - Perl API to oFono's Modem Manager

=cut

our $VERSION = '0.001';

use base qw(Net::oFono::Helpers::EventMgr);

use Net::DBus qw(:typing);

use Data::Dumper;

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Net::oFono::Manager;

    my $oMgr = Net::oFono::Manager->new();
    my @modems = $oMgr->GetModems();
    my ($mcc, $mnc, $lac, ...) = $

=head1 METHODS

=head2 new

=cut

sub new
{
    my ($class, %events) = @_;

    my $self = $class->SUPER::new(%events);

    bless( $self, $class );
    $self->{modems} = {};

    $self->_init();

    return $self;
}

sub _init
{
    my $self = $_[0];

    my $bus = Net::DBus->system();

    $self->{manager} = $bus->get_service("org.ofono")->get_object( "/", "org.ofono.Manager" );

    my $on_modem_added = sub { return $self->onModemAdded(@_); };
    $self->{sig_modem_added} = $self->{manager}->connect_to_signal( "ModemAdded", $on_modem_added );

    my $on_modem_removed = sub { return $self->onModemRemoved(@_); };
    $self->{sig_modem_removed} =
      $self->{manager}->connect_to_signal( "ModemRemoved", $on_modem_removed );

    $self->GetModems(1);

    return;
}

sub DESTROY
{
    my $self = $_[0];

    defined($self->{manager}) and $self->{manager}->disconnect_from_signal( "ModemAdded",   $self->{sig_modem_added} );
    defined($self->{manager}) and $self->{manager}->disconnect_from_signal( "ModemRemoved", $self->{sig_modem_removed} );

    undef $self->{modems};
    undef $self->{manager};

    return;
}

=head2 GetModems

=cut

sub GetModems
{
    my ( $self, $force ) = @_;

    if ($force)
    {
        my @modem_lst = @{ $self->{manager}->GetModems() };
        my %modems;

        foreach my $modem (@modem_lst)
        {
            $modems{ $modem->[0] } = $modem->[1];
        }

        $self->{modems} = \%modems;
    }

    return wantarray ? %{ $self->{modems} } : $self->{modems};
}

sub onModemAdded
{
    my ( $self, $modem, $mdata ) = @_;

    $self->{modems}->{$modem} = $mdata;
    $self->trigger_event("ON_MODEM_ADDED", $modem);

    return;
}

sub onModemRemoved
{
    my ( $self, $modem ) = @_;

    delete $self->{modems}->{$modem};
    $self->trigger_event("ON_MODEM_REMOVED", $modem);

    return;
}

1;
