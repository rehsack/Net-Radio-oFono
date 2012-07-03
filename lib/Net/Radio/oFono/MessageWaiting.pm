package Net::Radio::oFono::MessageWaiting;

use 5.010;
use strict;
use warnings;

=head1 NAME

Net::Radio::oFono::MessageWaiting - provide MessageWaiting interface for Modem objects

=cut

our $VERSION = '0.001';

use Net::DBus qw(:typing);

use base qw(Net::Radio::oFono::Modem);

=head1 SYNOPSIS

  my $oFono = Net::Location::oFono->new();
  my @modems = Net::Location::oFono->get_modems();
  foreach my $modem_path (@modems) {
    my $msgwait = Net::Location::oFono->get_modem_interface($modem_path, "MessageWaiting");
    say "VoicemailWaiting: ", 0+$msgwait->GetProperty("VoicemailWaiting"), # boolean
        "VoicemailMessageCount: ", 0+$msgwait->GetProperty("VoicemailMessageCount"), # byte
        "VoicemailMailboxNumber: ", $msgwait->GetProperty("VoicemailMailboxNumber"); # string
  }

=head1 INHERITANCE

  Net::Radio::oFono::MessageWaiting
  ISA Net::Radio::oFono::Modem
    ISA Net::Radio::oFono::Helpers::EventMgr
    DOES Net::Radio::oFono::Roles::RemoteObj
    DOES Net::Radio::oFono::Roles::Properties

=head1 METHODS

No new ones.

See C<ofono/doc/message-waiting.txt> for valid properties and detailed
action description and possible errors.

=cut

1;
