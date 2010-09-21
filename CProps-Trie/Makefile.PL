use strict;
use warnings;
use Cwd;
use Inline::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
              NAME              => 'CProps::Trie',
              AUTHOR            => 'shabble <shabble+cpan@metavore.org>',
              VERSION_FROM      => 'lib/CProps/Trie.pm', # finds $VERSION
              ABSTRACT_FROM     => 'lib/CProps/Trie.pm',
              PL_FILES          => {},
              PREREQ_PM         => {
                                    'Test::More'        => 0,
                                    'Inline'            => 0,
                                    'Inline::C'         => 0,
                                    'Inline::MakeMaker' => 0,
                                    'Carp'              => 0,
                                    'MooseX::Declare'   => 0,
                                   },
              dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
              clean               => {
                                      FILES => 'CProps-Trie-* Trie.inl _Inline Trie.pm'
                                     },
             );

# XXX:
# filthy hack. Fix Inline::MakeMaker to use actual documented APIs
# and not just open teh makefile afterwards.

unless (-e './Trie.pm') {
    system 'ln', '-s', './lib/CProps/Trie.pm', 'Trie.pm';
    print "Fixed your damn location\n";
}
