#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use Data::Dumper;
#use Devel::Peek qw/Dump DumpArray/;

BEGIN {
    use_ok 'CProps::Trie';
}

subtest 'remove nonexistent object' => sub {
    my $trie = new_ok 'CProps::Trie';
    is($trie->remove('aaa'), undef);

    done_testing;
};

subtest 'remove returns object' => sub {
    my $trie = new_ok 'CProps::Trie';
    my @things = qw/a abc addd q asf eeee qwerty xxx/;
    foreach (@things) {
        $trie->add($_, $_);
    }

    # can retrieve
    foreach (@things) {
        is($trie->get($_), $_);
    }

    is($trie->size, scalar @things);
    my $i = 0;
    foreach (@things) {
        my $ret = $trie->remove($_);
        is($ret, $_);
        is($trie->size, scalar(@things) - ++$i);
    }

    # all gone.
    foreach (@things) {
        is($trie->get($_), undef);
    }

    done_testing;
};

done_testing;
