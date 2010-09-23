#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use Data::Dumper;
use Devel::Peek qw/Dump DumpArray/;
use Devel::FindRef;

BEGIN {
    use_ok 'CProps::Trie';
}


my $trie = new_ok 'CProps::Trie';

my @foo = qw/a b abc q efd  abdce eeee x xxx xxxxy/;

for (@foo) {
    ok($trie->add($_, $_));
}

my @children = $trie->children('a');
is_deeply(\@children, [qw/a abc abdce/]);

my @c2 = $trie->children('xx');
is_deeply(\@c2, [qw/xxx xxxxy/]);


# TODO: why doesn't specifying the root (as '') work?
my @c3 = $trie->children(undef);
diag(Dumper(\@c3));


done_testing;
