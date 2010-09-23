#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
# use Test::Exception;

#use Data::Dumper;
# use Devel::Peek qw/Dump DumpArray/;
# use Devel::FindRef;

BEGIN {
    use_ok 'CProps::Trie';
}

my $trie = new_ok 'CProps::Trie';

ok($trie->add("array", [qw/1 2 3/]));
#my $ret = $trie->get("array");
#DumpArray($trie->get("array"));

ok($trie->remove('array'));
#diag Dumper($foo);

#ok($trie->add("array", 'SCALAR'));
#is($trie->get("array"), 'SCALAR');

done_testing;
