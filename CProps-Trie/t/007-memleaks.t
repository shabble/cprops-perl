#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use Devel::Size qw/total_size/;
use Number::Bytes::Human qw(format_bytes);
# SKIP: {
#     skip 'set $ENV{TRIE_MEMCHECK} to run this test', 2 unless $ENV{TRIE_MEMCHECK};

#     eval 'use Test::Valgrind';
#     plan skip_all => 'Test::Valgrind is required to test your'
#       . 'distribution with valgrind' if $@;

BEGIN {
    use_ok 'CProps::Trie';
}

#     #TODO: more here once I work ou how to use it?
# }

diag "Mem usage: " . format_bytes(get_ps_mem_usage());
diag "pid: $$";

my $payload = 'x' x 850;
diag "Payload: ". format_bytes(total_size($payload));
my $mem_last = 0;
for (1..100) {

    my $trie = CProps::Trie->new;

    my $buf = '';
    my $keysize_sum = 0;
    my $internal_cnt = 0;
    for my $char ('a'..'z') {
        $buf .= $char;

        for my $char2 ('a'..'z') {
            $buf .= $char2;
            $keysize_sum += length $buf;
            $trie->add($buf, $payload);
            $internal_cnt++;
        };

    }

    my $mem = get_ps_mem_usage() * 1024;
    my $delta = $mem - $mem_last;
    $mem_last = $mem;

    diag "Internal iterations: $internal_cnt";
    diag "Mem usage: " . format_bytes($mem);
    diag "Delta Mem usage: " . format_bytes($delta);
    diag "total keys mem: $keysize_sum";
    diag "mem/iter = " . format_bytes(int($delta/$internal_cnt));
    #$trie->DEMOLISH();
    $trie->remove_all;
    diag "trie size: " . $trie->size;
    diag "Loop $_";
}

diag "done, sleeping";
pass;

sleep 10;

done_testing;


sub get_ps_mem_usage {
    my $pid = $$;
    my @ans = qx/ps -o rss -p $pid/;
    chomp @ans;
    my $line = $ans[1];
    #diag "Line is $line";
    if ($line =~ m/^\s*(\d+)\s*$/) {
        my $mem = $1;
        return $mem;
    }
}
