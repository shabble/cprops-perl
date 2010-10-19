#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use CProps::Trie;
use Devel::Peek qw/Dump DumpArray SvREFCNT/;

{
    #my $trie = 
    lives_ok { CProps::Trie->new; } 'new lived';

    # diag Dump $trie;

    # undef $trie;

    # diag Dump $trie;
}

diag "Meep";

done_testing;
