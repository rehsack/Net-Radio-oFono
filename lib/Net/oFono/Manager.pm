package Net::oFono::Manager;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::oFono::Manager - Perl API to oFono's Modem Manager

=cut

our $VERSION = '0.001';

use List::MoreUtils qw(firstidx);
use Scalar::Util qw(blessed refaddr);

use Net::DBus;

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
    my ($class) = @_;

    my $self = bless( { modems => {}, notify => [] }, $class );

    $self->_init();

    return $self;
}

sub _init
{
    my $self = $_[0];

    my $bus           = Net::DBus->system();

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

    $self->{manager}->disconnect_from_signal( "ModemAdded",   $self->{sig_modem_added} );
    $self->{manager}->disconnect_from_signal( "ModemRemoved", $self->{sig_modem_removed} );

    undef $self->{modems};
    undef $self->{manager};

    return $self->SUPER::DESTROY();
}

sub add_notify
{
    my ($self, $obj) = @_;

    my $refelem = refaddr($obj);
    my $idx = firstidx( sub { refaddr($_) == $refelem; }, @{$self->{notify}} );

    $idx < 0 and croak( "Already there" );

    # probably weaken() the reference ...
    push( @{$self->{notify}}, $obj );

    return;
}

sub remove_notify
{
    my ($self, $obj) = @_;

    my $refelem = refaddr($obj);
    my $idx = firstidx( sub { refaddr($_) == $refelem; }, @{$self->{notify}} );
    0 <= $idx and return splice( @{$self->{notify}}, $idx, 1 );

    croak( "Not found" );
}

=head2 GetModems

=cut

sub GetModems
{
    my ( $self, $force ) = @_;

    if( $force )
    {
	my @modem_lst = @{$self->{manager}->GetModems()};
	my %modems;

	foreach my $modem (@modem_lst)
	{
	    $modems{$modem->[0]} = $modem->[1];
	}

	$self->{modems} = \%modems;
    }

    return wantarray ? %{ $self->{modems} } : $self->{modems};
}

sub onModemAdded
{
    my ( $self, $modem, $mdata ) = @_;

    $self->{modems}->{$modem} = $mdata;
    foreach my $notify (@{$self->{notify}})
    {
	$notify->modem_added($modem, $mdata);
    }

    return;
}

sub onModemRemoved
{
    my ( $self, $modem ) = @_;

    delete $self->{modems}->{$modem};
    foreach my $notify (@{$self->{notify}})
    {
	$notify->modem_removed($modem);
    }

    return;
}

1;
