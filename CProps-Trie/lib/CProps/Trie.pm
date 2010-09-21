use strictures 1;

use MooseX::Declare;

class CProps::Trie {
    use CProps;

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
        return CProps::trie_create();
    }

    method size() {
        return CProps::trie_count($self->_trie);
    }

    method add(Str $key, $val) {
        my $ret = CProps::trie_add($self->_trie, $key, $val);
        $self->_keys->{$key} = 1 if $ret;
        return $ret;
    }

    method remove(Str $key) {
        my $ret = CProps::trie_remove($self->_trie, $key);
        delete $self->_keys->{$key} if $ret;
        return $ret;
    }

    method prefixes(Str $key) {
        return CProps::trie_prefixes($self->_trie, $key);
    }

    method prefix_match(Str $key) {
        return CProps::trie_prefix_match($self->_trie, $key);
    }

    method get(Str $key) {
        return CProps::trie_exact_match($self->_trie, $key);
    }

    method children(Str $key) {
        return CProps::trie_submatch($self->_trie, $key);
    }

    method DEMOLISH {
        CProps::trie_destroy($self->_trie);
    }
}
