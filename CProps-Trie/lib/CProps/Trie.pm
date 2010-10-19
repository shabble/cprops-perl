use strict;
use warnings;

use MooseX::Declare;

class CProps::Trie {

    our $VERSION = '0.02';
    require XSLoader;
    XSLoader::load('CProps::Trie', $VERSION);

    # Class::XSAccessor->import(accessors =>
    #                           {
    #                            _trie => '_trie',
    #                            _keys => '_keys'
    #                           },
    #                           replace => 1);

    has '_trie'
      => (
          is      => 'ro',
          isa     => 'Ref',
          builder => '_build_trie',
          clearer => '_clear_trie',
          lazy    => 1,
         );

    has '_keys'
      => (
          traits  => [qw/Hash/],
          is      => 'ro',
          isa     => 'HashRef',
          default => sub { {} },
          handles => {
                      keys        => 'keys',
                      _clear_keys => 'clear',
                     },
         );

    sub _build_trie {
        return _trie_create();
    }

    sub size {
        my $self = shift;
        return _trie_count($self->_trie);
    }

    sub add {
        my ($self, $key, $val) = @_;

        if (not defined($key) or ref($key) ne '') {
            die "Key must be string";
        }

        if (exists $self->_keys->{$key}) {
            $self->remove($key);
        }

        my $ret = _trie_add($self->_trie, $key, $val);
        $self->_keys->{$key} = 1 if $ret;
        return $ret;
    }

    sub get {
        my ($self, $key) = @_;
        return _trie_exact_match($self->_trie, $key);
    }

    sub remove {
        my ($self, $key) = @_;
        my $ret = _trie_remove($self->_trie, $key);
        delete $self->_keys->{$key} if $ret;
        return $ret;
    }

    sub remove_all {
        my $self = shift;

        my @keys = $self->keys;
        foreach my $k (@keys) {
            $self->remove($k);
        }

        $self->_clear_keys;
    }

    sub prefixes {
        my ($self, $key) = @_;
        return _trie_prefixes($self->_trie, $key);
    }

    sub prefix_match {
        my ($self, $key) = @_;
        return _trie_prefix_match($self->_trie, $key);
    }


    sub children {
        my ($self, $key) = @_;
        return _trie_submatch($self->_trie, $key);
    }

    sub DEMOLISH {
        my $self = shift;
        #print "Destroying Trie\n";

        $self->remove_all;
        #print "done the removeall\n";
        _trie_destroy($self->_trie);
        #print "done the destroy\n";
        $self->_clear_trie;
        print "cleared the trie ref\n";
    }

}

__END__

=head1 NAME

CProps::Trie - Perl interface to the I<cprops> C-Prototypes Trie implementation

=head1 SYNOPSIS

  use CProps::Trie;
  my $trie = CProps::Trie->new;
  $trie->add('key', 'value');
  my $val = $trie->get('key');
  my $removed_val = $trie->remove($key);

  ... add more things ...

  my @prefixes = $trie->prefixes($key);
  my $all_keys = $trie->keys;

  my $trie_size = $trie->size;


=head1 DESCRIPTION

This module provides a fast XS interface to a trie datastructure.

=head2 EXPORT

Exports nothing.

=head2 METHODS

=over

=item C<new>

Constructs a new CProps::Trie instance. Takes no additional parameters.

=item C<size>

Returns the number of elements currently stored in the trie.

=item C<add $key, $value>

Adds a new key -> value mapping to the trie. C<$key> must be stringified before
being passed to this method.  C<$value> can be either a scalar, or a reference
to a more complex structure.  Returns true if the item was successfully added,
or false otherwise.  Note that it is unwise to pass C<undef> as a value, since
many of the other functions use that as a return value to indicate failure.

The Trie structure requires that all keys be unique. Calling this method with a key
which already exists will overwrite the original value.

=item C<get $key>

Returns the value of the specified key, or C<undef> if no entry matching the key
is found.

=item C<keys>

Returns a list of all of the keys currently stored in the trie. This list is
stored externally to the trie (in a hash), and hence, has no reliable ordering.
Returns an empty list if the trie is empty.

=item C<remove $key>

Removes an entry from the trie. Returns the value removed on success, or
C<undef> on failure.

=item C<remove_all>

Removes all entries from the trie. No useful value is returned.

=item C<prefix_match $key>

Returns a 2-element list containing the number of prefixes found for C<$key>, and
the value of the longest matching prefix. Return C<(0, undef)> if no matches could
be found.

=item C<prefixes $key>

Returns a list of all the values for keys in the trie which are a prefix of C<$key>.
Returns an empty list if no matches were found.

=item C<children $key>

returns a list containing all entries in subtree under path given by C<$key>.
The key must contain at least one character -- you cannot use C<''> to start
at the root. Returns an empty list if there are no children of the specified
key.

B<TODO: clarify the exact behaviour here>

=item C<DEMOLISH>

internal function. Documented here only to keep POD::Coverage happy.

=back

=head1 SEE ALSO

L<http://cprops.sourceforge.net/>

L<http://cprops.sourceforge.net/cp_trie.3.html>

=head1 AUTHOR

shabble, E<lt>shabble+cpan@metavore.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by shabble

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
