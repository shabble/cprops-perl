#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

#use CProps;
use Data::Dumper;
#CProps::greet();
BEGIN {
    use lib '.';
    use_ok 'CProps::Trie';
}
my $trie = new_ok 'CProps::Trie';
can_ok($trie, 'add', 'prefixes');

#my $ret = $trie->add("moo", "moo");
#diag("Ret is $ret");
ok($trie->add("moo", "cow"));
ok($trie->add("bar", "horse"));

is($trie->remove("moo"), 'cow');
is(!$trie->remove("bacon"), 1);

is_deeply([$trie->prefixes("bar")], [qw/horse/]);

my @exp = qw/moo moose moomin mongoose monday m/;

for my $x (@exp) {
    ok($trie->add($x, $x));
}

is_deeply([$trie->prefixes("moose")], [qw/m moo moose/]);
is_deeply([$trie->prefixes("moo")], [qw/m moo/]);
is_deeply([$trie->prefixes("m")], [qw/m/]);


my ($count, $closest) = $trie->prefix_match('mongolian');
is($count, 1); # Sure?
is($closest, 'm');

$trie->add('mon', 'mon');
($count, $closest) = $trie->prefix_match('mongolian');
is($count, 2);
is($closest, 'mon');

ok(!$trie->match("banana"));
is($trie->match("bar"), 'horse');

# how to test for memory leaks?

# for (1..1000) {
#     my $new_trie = CProps::Trie->new;
#     undef $new_trie; # free it again.
# }
# sleep 10;

#throws_ok(sub {
ok($trie->add("wombat", [qw/1 2 3/]));
my $ret = $trie->match("wombat");

isa_ok($ret, 'ARRAY');
is_deeply($ret, [qw/1 2 3/]);

ok($trie->add("wombat", 'bacon'));
is($trie->match("wombat"), 'bacon');

done_testing;
