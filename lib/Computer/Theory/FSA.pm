# Finite State Automaton
#
#    { Q, Z, T, S, F }
#      |  |  |  |  `---> Is a set of final (or accepting) states.
#      |  |  |  `------> Is the starting state.
#      |  |  `---------> Is the transition function..
#      |  `------------> Is a alphabet.
#      `---------------> Is a finite set of states.
#
# Copyright 2003 Fabiano Reese Righetti <frighetti@cpan.org>
# All rights reserved.
#
#     This  program  is  free software; you can redistribute it and/or
# modify  it  under  the  terms  of  the GNU General Public License as
# published  by  the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#    This  program  is distributed in the hope that it will be useful,
# but  WITHOUT  ANY  WARRANTY;  without  even  the implied warranty of
# MERCHANTABILITY  or  FITNESS  FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

package Computer::Theory::FSA;
require 5.005;

=head1 NAME

Computer::Theory::FSA - Computer theory of Finite State Automanton.

=head1 SYNOPSIS

 #!/usr/bin/perl
 
 use Computer::Theory::FSA;
 
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
 
 my $valide = $FA->DFA($word);

=head1 DESCRIPTION

"A  Finite  State  Automaton  is  an  abstract  machine  used in the
study  of computation and languages that has only a finite, constant
amount of memory (the state). It can be conceptualised as a directed
graph.  There  are  a  finite  number  of states, and each state has
transitions  to  zero  or more states. There is an input string that
determines  which  transition is followed. Finite state machines are
studied  in  automata  theory,  a  subfield  of theoretical computer
science". [Wikipedia - Mon Jun 23 2003]

=head1 METHODS

=over 4

=cut

use vars qw($VERSION);
use strict;
use warnings;

BEGIN
{
   our $VERSION = '0.1_04';
}

=item B<new>

The constructor method.

 my $FA = new Computer::Theory::FSA();

=cut

sub new
{
   my $type  = shift;
   my $class = ref $type || $type;

   my $self  = {
                Q => [],
                Z => [],
                S => '',
                F => [],
                T => {},
                @_,
               };

   bless  $self, $class;
   return $self;
}

=item B<addState>

Set new state in the list of states.

 $FA->addState("qX");

=cut

sub addState
{
   my $self  = shift;
   my $state = shift;

   if (defined $state) {
      push(@{$self->{Q}}, $state)
         if &_search(\@{$self->{Q}}, $state) < 0;
   }
}

=item B<delState>

Remove state in the list of states.

 $FA->delState("qX");

=cut

sub delState
{
   my $self     = shift;
   my $state    = shift;

   if (defined $state) {
      my $position = &_search(\@{$self->{Q}}, $state);
      splice(@{$self->{Q}}, $position, 1) if $position > -1;
   }
}

=item B<getState>

Get the list of states.

 foreach my $state ($FA->getState()) {
    print $state." ";
 }

=cut

sub getState
{
   my $self = shift;

   return @{$self->{Q}};
}

=item B<addAlphabet>

Set new caracter in the list of alphabet.

 $FA->addAlphabet("x");

=cut

sub addAlphabet
{
   my $self     = shift;
   my $caracter = shift;

   if (defined $caracter) {
      push(@{$self->{Z}}, $caracter)
         if &_search(\@{$self->{Z}}, $caracter) < 0;
   }
}

=item B<delAphabet>

Remove caracter in the list of alphebet.

 $FA->delAlphabet("x");

=cut

sub delAlphabet
{
   my $self     = shift;
   my $caracter = shift;
   my $position = &_search(\@{$self->{Z}}, $caracter);

   if (defined $caracter) {
      splice(@{$self->{Z}}, $position, 1) if $position > -1;
   }
}

=item B<getAlphabet>

Get the list of alphabet.

 foreach my $caracter ($FA->getAlphabet()) {
    print $i." ";
 }

=cut

sub getAlphabet
{
   my $self = shift;
                                                                                                                             
   return @{$self->{Z}};
}

=item B<setStarting>

Attribute starting state.

 $FA->setStarting("qX");

=cut

sub setStarting
{
   my $self  = shift;
   my $state = shift;

   if (defined $state) {
      $self->{S} = $state if &_search(\@{$self->{Q}}, $state) > -1;
   }
}

=item B<getStarting>

Get starting state.

 my $starting = $FA->getStarting();

=cut

sub getStarting
{
   my $self = shift;

   return $self->{S};
}

=item B<addFinal>

Set new state in the list of final states.

 $FA->addFinal("qX");

=cut

sub addFinal
{
   my $self  = shift;
   my $state = shift;

   if (defined $state) {
      push(@{$self->{F}}, $state)
         if &_search(\@{$self->{Q}}, $state) > -1 &&
            &_search(\@{$self->{F}}, $state) < 0;
   }
}

=item B<delFinal>

Remove state in the list of final states.

 $FA->delFinal("qX");

=cut

sub delFinal
{
   my $self     = shift;
   my $state    = shift;
   my $position = &_search(\@{$self->{F}}, $state);

   if (defined $state) {
      splice(@{$self->{F}}, $position, 1) if $position > -1;
   }
}

=item B<getFinal>

Get the list of final states.

 foreach my $fstate ($FA->getFinal()) {
    print $fstate." ";
 }

=cut

sub getFinal
{
   my $self = shift;

   return @{$self->{F}};
}

=item B<addTransition>

Set new transition in the list of transitions.

 $FA->addTransition("x","qX","qY");

=cut

sub addTransition
{
   my $self     = shift;
   my $caracter = shift;
   my $from     = shift;
   my $destine  = shift;

   if (defined $destine) {
      push(@{$self->{T}{$caracter}{$from}},$destine)
         if &_search(\@{$self->{Z}}, $caracter) > -1 &&
            &_search(\@{$self->{Q}}, $from) > -1 &&
            &_search(\@{$self->{Q}}, $destine) > -1 &&
            &_search(\@{$self->{T}{$caracter}{$from}}, $destine) < 0;
   }
}

=item B<delTransition>

Remove transition in the list of transitions.

 $FA->delTransition("x","qX","qY");
 $FA->delTransition("x","qX");

=cut

sub delTransition
{
   my $self     = shift;
   my $caracter = shift;
   my $from     = shift;
   my $destine  = shift;
   my $position = -1;

   if (defined $destine) {
      $position = &_search(\@{$self->{T}{$caracter}{$from}},$destine);
      splice(@{$self->{T}{$caracter}{$from}}, $position, 1)
            if $position > -1;
      delete($self->{T}{$caracter}{$from})
            if $#{$self->{T}{$caracter}{$from}} < 0;
   } elsif (defined $from) {
      delete($self->{T}{$caracter}{$from});
   }
}

=item B<getTransition>

Get the list of transitions.

 foreach my $caracter (sort keys %tt) {
    foreach my $from (sort keys %{$tt{$caracter}}) {
       print "             $caracter - $from => ";
       foreach my $destine (@{$tt{$caracter}{$from}}) {
          print "$destine ";
       }
       print "\n";
    }
 }

=cut

sub getTransition
{
   my $self = shift;
                                                                                                                             
   return %{$self->{T}};
}

=item B<DFA>

Algorithm of valide the Deterministic Finite Automaton.
"The  machine  starts  in  the  start state and reads in a string of
symbols  from  its  alphabet.  It  uses the transition function T to
determine the next state using the current state and the symbol just
read. If, when it has finished reading, it is in an accepting state,
it  is said to accept the string, otherwise it is said to reject the
string.  The set of strings it accepts form a language, which is the
language the DFA recognises". [Wikipedia - Mon Jun 23 2003]

 my $valide = $FA->DFA('xxx');

=cut

sub DFA
{
   my $self = shift;
   my $word = shift;
   my @word = split(//, defined $word ? $word : "" );

   return($#word > -1 ? ${&_dfa($self, \@word, $self->{S}, 0)}[0] : 0);
}

sub _dfa
{
   my ($self,$word,$state,$position) = @_;
   my $valide = 1;

   if ((defined $self->{T}{$word->[$position]}{$state}) and
       ($#{$self->{T}{$word->[$position]}{$state}} == 0)) {
      ($valide,$state) = $position < $#{$word} ?
                         @{&_dfa($self,$word,
                          $self->{T}{$word->[$position]}{$state}[0],
                          ++$position)} :
                         ($valide,
                          $self->{T}{$word->[$position]}{$state}[0]);
   } else {
      ($valide,$state) = (0, '');
   }

   if ($valide) {
      for my $i (@{$self->{F}}) {
         if ($state ne $i) {
            $valide = 0;
         } else {
            $valide = 1;
            last;
         }
      }
   }

   return([$valide, $state]);
}

# Valide Non-deterministic Finite Automaton.
#sub NFA
#{
#   my $self = shift;
#   my @word = split(//, shift);
#
#   return(${&_nfa($self, \@word, $self->{S}, 0)}[0]);
#}

#sub _nfa
#{
#}

# Search position of the element in the Array.
sub _search
{
   my $array    = shift;
   my $element  = shift;
   my $position = -1;

   for my $i (0 .. $#{$array}) {
      if ($array->[$i] eq $element) {
         $position = $i;
      }
   }

   return $position;
}

1;
__END__

=back

=head1 SEE ALSO

Wikipedia documentation.

=head1 AUTHOR

Fabiano Reese Righetti <frighetti@cpan.org>

=head1 COPYRIGHT

Copyright 2003 Fabiano Reese Righetti <frighetti@cpan.org>
All rights reserved.

This  code  is  free  software released under the GNU General Public
License,  the full terms of which can be found in the "COPYING" file
in this directory.

=cut
