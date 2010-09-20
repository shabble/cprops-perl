use strictures 1;

use MooseX::Declare;

class CProps::Trie {
    use CProps;

    has '_trie'
      => (
          is => 'ro',
          isa => 'Ref',
          builder => '_build_trie',
         );


    method _build_trie {
        return CProps::trie_create();
    }

    method add($key, $val) {
        return CProps::trie_add($self->_trie, $key, $val);
    }

    method remove($key) {
        return CProps::trie_remove($self->_trie, $key);
    }

    method prefixes($key) {
        return CProps::trie_prefixes($self->_trie, $key);
    }

    method prefix_match($key) {
        return CProps::trie_prefix_match($self->_trie, $key);
    }

    method match($key) {
        return CProps::trie_exact_match($self->_trie, $key);
    }

    method DEMOLISH {
        CProps::trie_destroy($self->_trie);
    }
}
