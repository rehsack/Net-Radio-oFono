package Net::oFono;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::oFono - Perl API to oFono

=cut

our $VERSION = '0.001';

use Net::oFono::Manager;
use Net::oFono::Modem;
use Net::oFono::SimManager;
use Net::oFono::NetworkRegistration;

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Net::oFono;

    my $oFono = Net::oFono->new();
    my @modems = $oFono->getModems();
    my ($mcc, $mnc, $lac, ...) = $

=cut

my $instance;

=head1 SUBROUTINES/METHODS

=head2 get_instance

=cut

sub get_instance
{
    $instance and return $instance;

    $instance = bless( {}, __PACKAGE__ );

    $instance->{manager} = Net::oFono::Manager->new();
    my %modems = $instance->{manager}->GetModems();
    my %modem_objects;
    foreach my $modem (keys %modems)
    {
	$modem_objects{$modem}->{modem} = Net::oFono::Modem->new($modem);
	# $modem_objects{$modem}->{simmgr} = Net::oFono::SimManager->new($modem);
	# $modem_objects{$modem}->{nwreg} = Net::oFono::NetworkRegistration->new($modem);
    }
    $instance->{modems} = \%modem_objects;

    $instance->{manager}->add_notify($instance);

    return $instance;
}

=head2 new

=cut

no strict 'refs';

*new = \&get_instance;

use strict 'refs';

sub shutdown
{
    $instance or return;

    undef $instance;
}

sub DESTROY
{
    my $self = shift;

    $self->{manager}->remove_notify($self);

    return $self->SUPER::DESTROY();
}

=head2 modem_added

=cut

sub modem_added
{
    my ( $self, $modem, $mdata ) = @_;

    $self->{modems}->{$modem}->{modem} = Net::oFono::Modem->new($modem);
    # $self->{modems}->{$modem}->{simmgr} = Net::oFono::SimManager->new($modem);
    # $self->{modems}->{$modem}->{nwreg} = Net::oFono::NetworkRegistration->new($modem);

    return;
}

=head2 modem_removed

=cut

sub modem_removed
{
    my ( $self, $modem ) = @_;

    delete $self->{modems}->{$modem};
}

=head1 AUTHOR

Jens Rehsack, C<< <rehsack at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-ofono at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-oFono>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::oFono


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-oFono>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-oFono>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net-oFono>

=item * Search CPAN

L<http://search.cpan.org/dist/Net-oFono/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Jens Rehsack.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Net::oFono
