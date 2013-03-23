## Class to convert a pair of a word and yomi

#!/usr/bin/env perl
package KKCI2Pron::WordkkciConverter;

use strict;
use warnings;
use Carp;
use encoding 'utf-8';

our $DEBUG = 0;

# Table to refer to a word in converting a yomi
#
# 助詞: 「は」、「へ」、「を」
my %TABLE_CONVERT_WITH_WORD = (
    'は/ハ' => "は/ワ",
    'へ/ヘ' => "へ/エ",
    'を/ヲ' => "を/オ",
);

# Table to stop converting
# 句読点
my @TABLE_STOP_CONVERT = qw/、  ， 。 ．/;

# Constructor
#
# @param Mixed converter to convert a yomi to a pronunciation
sub new {
  my $class = shift;
  (@_ == 1) or die $!;
  my $instances = {
      'converter' => shift
  };
  bless $instances, $class;
}

# Convert a yomi of a word to a pronunciation
#
# @param String $word a word
# @param String $kkci a yomi
# @return String a pair of a word and pronunciation
sub convert {
    my $self = shift;
    (@_ == 2) or croak $!;
    my ($word, $kkci) = @_;

    my $wk = "$word/$kkci";
    if (defined($TABLE_CONVERT_WITH_WORD{$wk})) {
        $wk = $TABLE_CONVERT_WITH_WORD{$wk};
    } else {
        if (! grep /$kkci/, @TABLE_STOP_CONVERT) {
            $kkci = $self->{converter}->convert(\$kkci);
        }
        $wk = "$word/$kkci";
    }
    if ($DEBUG) { warn "word=$word, kkci=$kkci"; }
    return $wk;
}

1;
