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

my $str = "test";
my $key = 'a';

print "Key: \n";
Dump($key);
print "----------------------------\n\n";
print "Str: \n";
Dump($str);
print "----------------------------\n\n";

#print Devel::FindRef::track \$key;
#print Devel::FindRef::track \$str;
$trie->add($key, $str);
#print Devel::FindRef::track \$str;
print "Key: \n";
Dump($key);
print "----------------------------\n\n";
print "Str: \n";
Dump($str);
print "----------------------------\n\n";

#$trie->add('x', 2);


my $str2;
ok($str2 = $trie->get('a'));
ok($str2 = $trie->get('a'));
ok($str2 = $trie->get('a'));
is($str2, $str);

#print Devel::FindRef::track \$str;

Dump($str2);
my $str3 = $trie->remove('a');
Dump($str3);

done_testing;
exit 0;




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
