package Net::Radio::oFono::RadioSettings;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::Radio::oFono::RadioSettings - provide RadioSettings interface for Modem objects

=cut

our $VERSION = '0.001';

use Net::DBus qw(:typing);

use base qw(Net::Radio::oFono::Modem);

=head1 SYNOPSIS

  my $oFono = Net::Location::oFono->new();
  my @modems = Net::Location::oFono->get_modems();
  foreach my $modem_path (@modems) {
    my $rs = Net::Location::oFono->get_modem_interface($modem_path, "RadioSettings");
    $rs->SetProperty("TechnologyPreference", dbus_string("umts")); # only UMTS used for radio access
  }

=head1 INHERITANCE

  Net::Radio::oFono::RadioSettings
  ISA Net::Radio::oFono::Modem
    ISA Net::Radio::oFono::Helpers::EventMgr
    DOES Net::Radio::oFono::Roles::RemoteObj
    DOES Net::Radio::oFono::Roles::Properties

=head1 METHODS

No new ones.

See C<ofono/doc/radio-settings.txt> for detailed property description.

=cut

1;
