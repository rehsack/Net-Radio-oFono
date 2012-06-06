package Net::oFono::Helpers::IteratableContainer;

use strict;
use warnings;

use 5.010;

use overload
  q(-=)   => \&decrease_by,
  q(+=)   => \&increase_by,
  q(@{})  => \&as_array,
  q(${})  => \&curr_item,
  q(<>)   => \&iterate,
  q(bool) => sub { 1 },
  q(0+)   => \&n_elements;

=head1 NAME

Net::oFono::Helpers::IteratableContainer - simple container allows iterating over contained elements

=head1 DESCRIPTION

This package implements a class which will act as a container for items of
any type. In addition to Net::oFono::Helpers::Container it allows iterating
over it's content.

Per default following operators to the container instances are overloaded:

=over 4

=item C<@{}>

Gives plain access to the managed list of items.

=item C<bool>

Returns a boolean value (always true).

=item C<0+>

Returns the number of managed elements.

=item C<E<lt>E<gt>>

Iterates over all items and returns the currently selected on or undef,
if end of list is reached.

=item C<-=>

Reduces the iteration pointer by count.

=item C<+=>

Increases the iteration pointer by count.

=item C<${}>

Returns the currently selected item in an iteration.

=back

=head1 INHERITANCE

  Net::oFono::Helpers::IteratableContainer
  ISA Net::oFono::Helpers::Container

=head1 METHODS

=cut

sub _adjust_iter_idx
{
    my ( $self, $idx ) = @_;

    # ensure <> operator will take correctly next element
    if ( $self->{inIteration} && ( $self->{iteratorIndex} == $idx ) )
    {
        --$self->{iteratorIndex};
    }

    return;
}

=head2

Removes an item from the container.

B<Parameters>:

=over 4

=item I<item>

Item to remove from the container.

=back

B<Returns>:

The removed element in scalar mode and and array containing the removed
element at position 0 and it's index in the managed list at index 1 in
array mode.

=cut

sub remove
{
    my ( $self, $elem ) = @_;

    my $idx;
    ( undef, $idx ) = $self->SUPER::remove($elem);
    $self->_adjust_iter_idx($idx);

    return wantarray ? ( $elem, $idx ) : $elem;
}

sub decrease_by
{
    my $self = shift;
    $self->{iteratorIndex} -= $_[0];
    $self->{iteratorIndex} < 0 and $self->{iteratorIndex} = 0;
    return $self;
}

sub increase_by
{
    my $self = shift;
    $self->{iteratorIndex} += $_[0];
    $self->{iteratorIndex} > scalar( @{ $self->{elements} } )
      and $self->{iteratorIndex} = scalar( @{ $self->{elements} } );
    return $self;
}

sub as_array() { $_[0]->{elements}; }

sub iterate()
{
    my $self = shift;
    my $elem;

    unless ( $self->{inIteration} )
    {
        ++$self->{inIteration};
        $self->{iteratorIndex} = -1;
    }

    if ( ++$self->{iteratorIndex} < scalar( @{ $self->{elements} } ) )
    {
        $elem = $self->{elements}->[ $self->{iteratorIndex} ];
    }
    else
    {
        --$self->{inIteration};
    }

    return $elem;
}

sub curr_item()
{
    $_[0]->{inIteration} and return $_[0]->{elements}->[ $_[0]->{iteratorIndex} ];
    return;
}

sub DESTROY { $_[0]->clear(); }

#
1;    # Packages must always end like this
