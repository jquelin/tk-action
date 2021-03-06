use 5.010;
use strict;
use warnings;

package Tk::Action;
# ABSTRACT: action abstraction for tk

use Moose 0.92; # attribute helpers
use MooseX::Has::Sugar;
use MooseX::SemiAffordanceAccessor;
use Tk::Sugar;


# -- attributes & accessors

# a hash with action widgets.
has _widgets => (
    ro,
    traits  => ['Hash'],
    isa     => 'HashRef',
    default => sub { {} },
    handles => {
        rm_widget    => 'delete',
        _set_widget  => 'set',      # $action->_set_widget($widget, $widget);
        _all_widgets => 'values',   # my @widgets = $action->_all_widgets;
    },
);

# a list of bindings.
has _bindings => (
    ro,
    traits  => ['Array'],
    isa     => 'ArrayRef',
    default => sub { [] },
    handles => {
        _add_binding  => 'push',      # $action->_add_binding($binding);
        _all_bindings => 'elements',  # my @bindings = $action->_all_bindings;
    },
);

# whether the action is currently available
has is_enabled => (
    ro,
    traits  => ['Bool'],
    isa     => 'Bool',
    default => 1,
    handles => {
        _enable  => 'set',
        _disable => 'unset',
    },
);

=attr callback

The callback associated to the action. It is needed to create the
shortcut bindings. Required, no default.

=attr window

The window holding the widgets being part of the action object. It is
needed to create the shortcut bindings. Required, no default.

=cut

has callback => ( ro, required, isa => 'CodeRef'    );
has window   => ( ro, required, isa => 'Tk::Widget' );



# -- public methods

=method $action->add_widget( $widget );

Associate C<$widget> with C<$action>. Enable or disable it depending on
current action status.

=cut

sub add_widget {
    my ($self, $widget) = @_;
    $self->_set_widget($widget, $widget);
    $widget->configure( $self->is_enabled ? enabled : disabled );
}


=method $action->rm_widget( $widget );

De-associate C<$widget> from C$<action>.

=cut

# rm_widget() implemented in _widget attribute declaration


=method $action->add_binding( $binding );

Associate C<$binding> with C<$action>. Enable or disable it depending on
current action status. C<$binding> is a regular binding, as defined by
L<Tk::bind>.

It is not possible to remove a binding from an action.

=cut

sub add_binding {
    my ($self, $binding) = @_;
    $self->_add_binding($binding);
    $self->window->bind( $binding, $self->is_enabled ? $self->callback : '' );
}


=method $action->enable;

Activate all associated widgets and shortcuts.

=cut

sub enable {
    my $self = shift;
    $_->configure(enabled) for $self->_all_widgets;
    $self->window->bind( $_, $self->callback ) for $self->_all_bindings;
    $self->_enable;
}


=method $action->disable;

De-activate all associated widgets and shortcuts.

=cut

sub disable {
    my $self = shift;
    $_->configure(disabled) for $self->_all_widgets;
    $self->window->bind( $_, '' ) for $self->_all_bindings;
    $self->_disable;
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 SYNOPSIS

    my $action = Tk::Action->new(
        window   => $mw,
        callback => \&jfdi,
    );
    $action->add_widget( $menu_entry );
    $action->add_widget( $button );
    $action->add_binding( '<Control-F>' );
    $action->enable;
    ...
    $action->disable;


=head1 DESCRIPTION

Menu entries are often also available in toolbars or other widgets. And
sometimes, we want to enable or disable a given action, and this means
having to update everywhere this action is allowed.

This module helps managing actions in a L<Tk> GUI: just create a new
object, associate some widgets and bindings with C<add_widget()> and
then de/activate the whole action at once with C<enable()> or
C<disable()>.


=head1 SEE ALSO

You can look for information on this module at:

=over 4

=item * Search CPAN

L<http://search.cpan.org/dist/Tk-Action>

=item * See open / report bugs

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Tk-Action>

=item * Git repository

L<http://github.com/jquelin/tk-action>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Tk-Action>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Tk-Action>

=back
