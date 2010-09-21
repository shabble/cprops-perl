use strictures 1;

package CProps::Trie;

$CProps::Trie::VERSION = '0.01';

use Inline (
            C           => './src/cprops.c',
            NAME        => 'CProps::Trie',
            VERSION     => '0.01',
            TYPEMAPS    => "./src/typemap",
            LIBS        => '-L/opt/local/lib -lcprops',
            INC         => '/opt/local/include/cprops',
            FORCE_BUILD => 1,
           );

Inline->init();

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

__END__

=head1 NAME

CProps::Trie - Perl interface to the I<cprops> Trie implementation

=head1 SYNOPSIS

  use CProps::Trie;
  ...magic happens.

=head1 DESCRIPTION

Stub documentation for CProps::Trie, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

Nothing.

=head1 SEE ALSO

L<http://cprops.sourceforge.net/>

L<http://cprops.sourceforge.net/cp_trie.3.html>


Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

shabble, E<lt>shabble+cpan@metavore.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by shabble

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
