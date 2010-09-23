#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;


SKIP: {
    skip 'set $ENV{TRIE_MEMCHECK} to run this test', 2 unless $ENV{TRIE_MEMCHECK};

    eval 'use Test::Valgrind';
    plan skip_all => 'Test::Valgrind is required to test your'
      . 'distribution with valgrind' if $@;


    use_ok 'CProps::Trie';


    my $trie = new_ok 'CProps::Trie';
}

done_testing;
