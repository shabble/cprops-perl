#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use Data::Dumper;
#use Devel::Peek qw/Dump DumpArray SvREFCNT/;
# use Devel::FindRef;

BEGIN {
    use_ok 'CProps::Trie';
}



subtest 'simple scalars' => sub {
    my $trie = new_ok 'CProps::Trie';

    ok($trie->add('a', 'b'));
    is($trie->get('a'), 'b');

    ok($trie->add(2, 'horse'));
    is($trie->get(2), 'horse');

    done_testing;
};

subtest 'reference values' => sub {

    my $trie = new_ok 'CProps::Trie';
    ok($trie->add('x', [1, 2, 3, 4]));
    isa_ok($trie->get('x'), 'ARRAY');
    is_deeply($trie->get('x'), [1, 2, 3, 4]);

    ok($trie->add('h', { moo => 'cow', baa => 'sheep' }));
    my $ret = $trie->get('h');
    isa_ok($ret, 'HASH');
    is_deeply($ret, { moo => 'cow', baa => 'sheep' });


    # values are references.
    my $hashref = { a => 1, b => 2 };
    ok($trie->add('r', $hashref));
    my $hashret = $trie->get('r');
    isa_ok($hashret, 'HASH');
    is_deeply($hashret, $hashref);

    $hashref->{b} = 10;
    is($hashret->{b}, 10, 'updating reference changes trie contents');

    # but keys are not.
    my $key = 'moo';
    ok($trie->add($key, "banana"));
    $key = 'oink';
    is($trie->get($key), undef);
    is($trie->get('moo'), 'banana');

    dies_ok( sub {
                 $trie->add({a => 1}, 'moo');
             },
             'passing non-scalar as key dies');
    dies_ok( sub {
                 $trie->add(undef, 'moo');
             },
             'passing undef as key dies');

    my $hash2 = { q => 3 };
    my $hstr = "$hash2";
    ok($trie->add($hstr, $hash2), 'stringified hashref ok');
    is_deeply($trie->get($hstr), $hash2);

    done_testing;
};


subtest 'inserting duplicate keys' => sub {
    my $trie = new_ok 'CProps::Trie';
    my $first = 'first';
    my $second = 'second';
    ok($trie->add('x', $first));
    is($trie->get('x'), $first);

    is($trie->size, 1);

    ok($trie->add('x', $second));
    is($trie->get('x'), $second);
    is($trie->size, 1);

    my $ret;
    ok($ret = $trie->remove('x'));
    is($ret, $second);
    is($trie->size, 0);

    is($trie->get('x'), undef);

    done_testing;
};


subtest 'key with embedded nulls' => sub {

    my $trie = new_ok 'CProps::Trie';

    my $key = "foo\x00bar";

    throws_ok sub { $trie->add($key, "whatever") },
      qr/cannot contain embedded NUL/,
        'dies when key contains NUL';

    done_testing;
};

subtest 'utf-8 keys' => sub {
    my $trie = new_ok 'CProps::Trie';

    my $key = "foo\x{101}bar";

    ok($trie->add($key, 'something'));
    is($trie->get($key), 'something');
    is($trie->remove($key), 'something');

    done_testing;
};

done_testing;

__END__
