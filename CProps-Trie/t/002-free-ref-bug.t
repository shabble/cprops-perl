#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use Data::Dumper;
use Devel::Peek qw/Dump DumpArray/;

BEGIN {
    use_ok 'CProps::Trie';
}


my $trie = new_ok 'CProps::Trie';
my $arr = [qw/1 2 3/];
ok($trie->add("array", $arr));
Dump($arr);
my $ret = $trie->get("array");
Dump($ret);

isa_ok($ret, 'ARRAY');
#is_deeply($ret, [qw/1 2 3/]);

my $del = ok($trie->remove('array'));
Dump($del);

#diag Dumper($foo);

#ok($trie->add("array", 'SCALAR'));
#is($trie->get("array"), 'SCALAR');

done_testing;
