#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

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

done_testing;

# my $trie = CProps::trie_create();
# #CProps::trie_add($trie, "a", "a");
# #CProps::trie_add($trie, "ab", "ab");
# #CProps::trie_add($trie, "abc", "abc");

# add($trie, qw/moo moose moomoo moocow m mo moosey/);

# my @foo = CProps::trie_prefixes($trie, 'moos');
# print Dumper(\@foo), "\n";
# my $ret = CProps::trie_destroy($trie);
# print "Destroy: $ret\n";


# sub add {
#     my ($trie, @things) = @_;
#     for my $thing (@things) {
#         print "Adding: $thing\n";
#         CProps::trie_add($trie, $thing, $thing);
#     }
# }

# #CProps::spam($trie, "abc");

# #print Dumper($trie);

# #my $trie = bacon::trie_create(0);


# # => q{
# #undef die
# #cp_trie* cp_trie_create(int);
# #
# #};



