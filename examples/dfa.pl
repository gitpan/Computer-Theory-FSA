#!/usr/bin/perl

use Computer::Theory::FSA;
use strict;
use warnings;

my $FA = new Computer::Theory::FSA();

$FA->addState("q0");
$FA->addState("q1");
$FA->addState("q2");
$FA->addState("q3");
$FA->addAlphabet("a");
$FA->addAlphabet("b");
$FA->setStarting("q0");
$FA->addFinal("q3");
$FA->addTransition("a","q0","q1");
$FA->addTransition("a","q1","q2");
$FA->addTransition("a","q2","q3");
$FA->addTransition("b","q0","q0");

print "     States: ";
foreach my $i ($FA->getState()) {
   print $i." ";
}

print "\n   Alphabet: ";
foreach my $i ($FA->getAlphabet()) {
   print $i." ";
}

print "\n   Starting: ".$FA->getStarting();

print "\n      Final: ";
foreach my $i ($FA->getFinal()) {
   print $i." ";
}

print "\nTransitions: \n";
my %tt = $FA->getTransition();
foreach my $i (sort keys %tt) {
   foreach my $j (sort keys %{$tt{$i}}) {
      print "             $i - $j => ";
      foreach my $k (@{$tt{$i}{$j}}) {
         print "$k ";
      }
      print "\n";
   }
}

my $word   = $ARGV[0] || "";
my $valide = $FA->DFA($word);
print "\n        DFA: \n";
print "                Word: $word\n";
printf "              Valide: %s\n",$valide ? "Yes" : "No";
