use strictures 1;

package CProps::Trie;

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('CProps::Trie', $VERSION);

use MooseX::Declare;

class CProps::Trie is dirty {



    has '_trie'
      => (
          is      => 'ro',
          isa     => 'Ref',
          builder => '_build_trie',
         );

    has '_keys'
      => (
          traits  => [qw/Hash/],
          is      => 'ro',
          isa     => 'HashRef',
          default => sub { {} },
          handles => {
                      keys => 'keys',
                     },
         );

    method _build_trie {
        return _trie_create();
    }

    method size() {
        return _trie_count($self->_trie);
    }

    method add(Str $key, $val) {
        my $ret = _trie_add($self->_trie, $key, $val);
        $self->_keys->{$key} = 1 if $ret;
        return $ret;
    }

    method remove(Str $key) {
        my $ret = _trie_remove($self->_trie, $key);
        delete $self->_keys->{$key} if $ret;
        return $ret;
    }

    method prefixes(Str $key) {
        return _trie_prefixes($self->_trie, $key);
    }

    method prefix_match(Str $key) {
        return _trie_prefix_match($self->_trie, $key);
    }

    method get(Str $key) {
        return _trie_exact_match($self->_trie, $key);
    }

    method children(Str $key) {
        return _trie_submatch($self->_trie, $key);
    }

    method DEMOLISH {
        _trie_destroy($self->_trie);
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

=item C<size>

=item C<add $key, $value>

=item C<get $key>

=item C<remove $key>

=item C<prefix_match $key>

=item C<prefixes $key>

=item C<children $key>

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
