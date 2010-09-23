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

subtest 'children' => sub {
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
    my @c3 = $trie->children('');
    is_deeply(\@c3, []);

#    diag(Dumper(\@c3));

    done_testing;
};


subtest 'prefixes' => sub {
    my $trie = new_ok 'CProps::Trie';

    my @foo = qw/a b abc q efd  abcde abdce eeee x xxx xxxxy/;
    $trie->add($_, $_) for @foo;

    my @prefixes;
    ok(@prefixes = $trie->prefixes('abcde'));

    is (scalar @prefixes, 3);
    is_deeply(\@prefixes, [qw/a abc abcde/]);

    ok(@prefixes = $trie->prefixes('xxxxy'));
    is (scalar @prefixes, 3);
    is_deeply(\@prefixes, [qw/x xxx xxxxy/]);

    @prefixes = $trie->prefixes('not a key');
    is (scalar @prefixes, 0);

    done_testing;
};

subtest 'prefix match' => sub {

    my $trie = new_ok 'CProps::Trie';

    my @foo = qw/a b abc q efd  abcde abdce eeee x xxx xxxxy/;
    $trie->add($_, $_) for @foo;

    my ($num, $longest);
    ok(($num, $longest) = $trie->prefix_match('xxxx'));
    is($num, 2);
    is($longest, 'xxx');

    ok(($num, $longest) = $trie->prefix_match('ttt'));
    is($num, 0);
    is($longest, undef);

    ok(($num, $longest) = $trie->prefix_match(''));
    is($num, 0);
    is($longest, undef);

    ok(($num, $longest) = $trie->prefix_match('abcde'));
    is($num, 3);
    is($longest, 'abcde', 'exact search matches itself');

    done_testing;
};

done_testing;
