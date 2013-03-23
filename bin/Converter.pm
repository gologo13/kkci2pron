#!/usr/bin/env perl
package KKCI2PRON::Converter;

use strict;
use warnings;
use Carp;

sub new {
  my $class = shift;
  bless {}, $class;
}

sub run {
    my $self = shift;
    while (<STDIN>) {
        chomp;
        my @ret;
        for (split(/\ /)) {
            my ($word, $kkci) = split(/\//);
            my $elem = KKCI2PRON::PhonemePron::wordkkci2pron->($word, $kkci);
            push(@ret, $elem);
        }
        print join(" ", @ret),"\n";
    }
}

1;
