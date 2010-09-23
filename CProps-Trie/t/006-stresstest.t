#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use Data::Dumper;
# use Devel::Peek qw/Dump DumpArray/;
# use Devel::FindRef;

BEGIN {
    use_ok 'CProps::Trie';
}

my $trie = new_ok 'CProps::Trie';

for my $i (1..1_000) {
    $trie->add('a' x $i, $i);
}

is($trie->size, 1_000);

undef $trie;
$trie = new_ok 'CProps::Trie';
for my $i (1..1000) {
    $trie->add("$i", $i);
}
is($trie->size, 1000);

undef $trie;
$trie = new_ok 'CProps::Trie';
for my $i (1..1000) {
    $trie->add($i, $i);
}
is($trie->size, 1000);

done_testing;
