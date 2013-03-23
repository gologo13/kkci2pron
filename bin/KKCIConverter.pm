## Class to convert a kkci to a pronunciation
#!/usr/bin/env perl
package KKCI2Pron::KKCIConverter;

use strict;
use warnings;
use feature qw(switch);
use encoding 'utf-8';
use Carp;
use Storable qw(dclone);

# constants
our $DEBUG = 0;
my $TYPE = {
    'CONVERTED'     => 0,
    'NOT_CONVERTED' => 1,
    'NA'            => 2
};
my @INCOMPLETE_CHARS = qw/ァ ィ ゥ ェ ォ ャ ュ ョ ー/;
my %INCOMPLETE_CHARS = map { $_ => 1 } @INCOMPLETE_CHARS;

# Constructor
#
# @param Mixed a converter to convert a phoneme
sub new {
  my $class = shift;
  (@_ == 1) or die $!;
  my $instances = {
      'converter' => shift
  };
  bless $instances, $class;
}

# convert a KKCI to a pronunciation with the specified converter
#
# @param String a reference of a kkci
# @return String a pronunciation
sub convert {
    my $self = shift;
    (@_ == 1) or croak $!;
    my ($ref_kkci) = @_;
    my $kkci_phoneme = yomi2phoneme($$ref_kkci);
    my ($type, $pron_phoneme) = $self->translate_phoneme(\$kkci_phoneme);

    my ($ret);
    given ($type) {
        when ($TYPE->{CONVERTED}) {
            my $pron = phoneme2yomi($pron_phoneme);
            if ($DEBUG) { carp "$$ref_kkci -> $kkci_phoneme -> $pron_phoneme -> $pron"; }
            $pron =~ s/\ //g;
            $ret = $pron;
        }
        when ($TYPE->{NOT_CONVERTED}) { $ret = $$ref_kkci; }
        when ($TYPE->{NA})            { $ret = "NA"; }
        default { croak "kkci2pron: $!"; }
    }
    if ($DEBUG) { carp "\n"; }
    return $ret;
};

# wrapper function for translating phoneme
#
# @param String a reference of a phoneme
# @return String a pair of the type of return-value and the translated phoneme
sub translate_phoneme {
    my $self = shift;
    my $ref_phoneme = shift || croak $!;

    my ($type, $phoneme);
    if (!validate_phoneme($ref_phoneme)) {
        # 数詞や非発音記号
        ($type, $phoneme) = ($TYPE->{NA}, "NA");
    } else {
        my $ref_src = dclone($ref_phoneme);
        my $dst = $self->{converter}->convert($ref_src);
        if ($$ref_src ne $dst) {
            ($type, $phoneme) = ($TYPE->{CONVERTED}, $dst);
        } else {
            ($type, $phoneme) = ($TYPE->{NOT_CONVERTED}, $$ref_phoneme);
        }
    }
    if ($DEBUG) { carp "type=$type, phoneme=$phoneme"; }
    return ($type, $phoneme);
}


# check if the phoneme is valid or not
#
# @param String a reference of phoneme
# @return Boolean 1 if it is valid. 0 if it isn't valid
sub validate_phoneme {
    my $ref_phoneme = shift || croak $!;
    return ($$ref_phoneme =~ /^([a-zA-Z:]|\s)+$/
            && $$ref_phoneme ne ":");
}

# check if the yomi is valid or not
#
# @param String a yomi
# @return 1 if it is valid. 0 if it isn't valid
sub validate_yomi {
    my $ref_yomi = shift || croak $!;
    return ($$ref_yomi =~ /^([ァ-ンヴ|ー|\s]+)$/);
}

# convert a pronunciation to a phoneme
#
# @param String a yomi
# @return String a phoneme
sub yomi2phoneme {
    (@_ == 1) or croak $!;

    my $yomi = shift;
    my $copy = $yomi;

    if ($yomi =~ m/^[ぁ-ん]+$/) {
        croak "$yomi: input must be a sequence of katakana characters";
    }
    if ($yomi =~ /[、。]/) {
        carp "$yomi includes at least one punctuation mark. \n"
             ."you might not preprocess for the training corpus.";
        return 'sp';
    }

    $yomi =~ s/ンー/ン/g;
    $yomi =~ s/ッー/ッ/g;
    $yomi =~ s/ー/: /g;

    $yomi =~ s/ヴァ/b a /g;
    $yomi =~ s/ヴィ/b i /g;
    $yomi =~ s/ヴェ/b e /g;
    $yomi =~ s/ウォ/w o /g;
    $yomi =~ s/ズィ/j i /g;
    $yomi =~ s/ジァ/j a /g;
    $yomi =~ s/ドゥ/d u /g;
    $yomi =~ s/フョ/hy o /g;
    $yomi =~ s/フュ/hy u /g;

    # "クォ","シィ","タァ","ナァ","カァ","ネェ" added.
    $yomi =~ s/イェ/i e /g;
    $yomi =~ s/ツォ/ts o /g;
    $yomi =~ s/ニェ/n i e /g;
    $yomi =~ s/ヒェ/h e /g;
    $yomi =~ s/ブィ/b i /g;
    $yomi =~ s/ミェ/m e /g;
    $yomi =~ s/クヮ/k a /g;
    $yomi =~ s/グヮ/g a /g;
    $yomi =~ s/スィ/s u i /g;
    $yomi =~ s/テュ/t e y u /g;
    $yomi =~ s/クォ/k u o /g;
    $yomi =~ s/シィ/sh i : /g;
    $yomi =~ s/タァ/t a a /g;
    $yomi =~ s/ナァ/n a a /g;
    $yomi =~ s/カァ/k a a /g;
    $yomi =~ s/ネェ/n e e /g;

    $yomi =~ s/ツァ/ts a /g;
    $yomi =~ s/ヴォ/b o /g;
    $yomi =~ s/ツィ/ts i /g;
    $yomi =~ s/キャ/ky a /g;
    $yomi =~ s/キュ/ky u /g;
    $yomi =~ s/キョ/ky o /g;
    $yomi =~ s/シャ/sh a /g;
    $yomi =~ s/シュ/sh u /g;
    $yomi =~ s/シェ/sh e /g;
    $yomi =~ s/ショ/sh o /g;
    $yomi =~ s/チァ/ch a /g;
    $yomi =~ s/チャ/ch a /g;
    $yomi =~ s/チュ/ch u /g;
    $yomi =~ s/チェ/ch e /g;
    $yomi =~ s/チョ/ch o /g;
    $yomi =~ s/ツェ/ts e /g;
    $yomi =~ s/ニャ/ny a /g;
    $yomi =~ s/ニュ/ny u /g;
    $yomi =~ s/ニョ/ny o /g;
    $yomi =~ s/ヒャ/hy a /g;
    $yomi =~ s/ヒュ/hy u /g;
    $yomi =~ s/ヒョ/hy o /g;
    $yomi =~ s/ミャ/my a /g;
    $yomi =~ s/ミュ/my u /g;
    $yomi =~ s/ミョ/my o /g;
    $yomi =~ s/リャ/ry a /g;
    $yomi =~ s/リュ/ry u /g;
    $yomi =~ s/リョ/ry o /g;
    $yomi =~ s/ギャ/gy a /g;
    $yomi =~ s/ギュ/gy u /g;
    $yomi =~ s/ギョ/gy o /g;
    $yomi =~ s/ビャ/by a /g;
    $yomi =~ s/ビュ/by u /g;
    $yomi =~ s/ビョ/by o /g;
    $yomi =~ s/ヂュ/dy u /g;
    $yomi =~ s/ヂョ/dy o /g;
    $yomi =~ s/ピャ/py a /g;
    $yomi =~ s/ピュ/py u /g;
    $yomi =~ s/ピョ/py o /g;
    $yomi =~ s/ヲ/o /g;
    $yomi =~ s/ティ/t i /g;
    $yomi =~ s/ファ/f a /g;
    $yomi =~ s/フィ/f i /g;
    $yomi =~ s/フェ/f e /g;
    $yomi =~ s/フォ/f o /g;
    $yomi =~ s/ジャ/j a /g;
    $yomi =~ s/ジュ/j u /g;
    $yomi =~ s/ジョ/j o /g;
    $yomi =~ s/ディ/d i /g;
    $yomi =~ s/デュ/d u /g;
    $yomi =~ s/ウェ/w e /g;
    $yomi =~ s/ウィ/w i /g;
    $yomi =~ s/カ/k a /g;
    $yomi =~ s/キ/k i /g;
    $yomi =~ s/ク/k u /g;
    $yomi =~ s/ケ/k e /g;
    $yomi =~ s/コ/k o /g;
    $yomi =~ s/サ/s a /g;
    $yomi =~ s/ス/s u /g;
    $yomi =~ s/セ/s e /g;
    $yomi =~ s/ソ/s o /g;
    $yomi =~ s/タ/t a /g;
    $yomi =~ s/トゥ/t u /g;
    $yomi =~ s/テ/t e /g;
    $yomi =~ s/ト/t o /g;
    $yomi =~ s/ナ/n a /g;
    $yomi =~ s/ニ/n i /g;
    $yomi =~ s/ヌ/n u /g;
    $yomi =~ s/ネ/n e /g;
    $yomi =~ s/ノ/n o /g;
    $yomi =~ s/ハ/h a /g;
    $yomi =~ s/ヒ/h i /g;
    $yomi =~ s/フ/f u /g;
    $yomi =~ s/ヘ/h e /g;
    $yomi =~ s/ホ/h o /g;
    $yomi =~ s/マ/m a /g;
    $yomi =~ s/ミ/m i /g;
    $yomi =~ s/ム/m u /g;
    $yomi =~ s/メ/m e /g;
    $yomi =~ s/モ/m o /g;
    $yomi =~ s/ヤ/y a /g;
    $yomi =~ s/ユ/y u /g;
    $yomi =~ s/ヨ/y o /g;
    $yomi =~ s/ラ/r a /g;
    $yomi =~ s/リ/r i /g;
    $yomi =~ s/ル/r u /g;
    $yomi =~ s/レ/r e /g;
    $yomi =~ s/ロ/r o /g;
    $yomi =~ s/ワ/w a /g;
    $yomi =~ s/ン/N /g;
    $yomi =~ s/ガ/g a /g;
    $yomi =~ s/ギ/g i /g;
    $yomi =~ s/グ/g u /g;
    $yomi =~ s/ゲ/g e /g;
    $yomi =~ s/ゴ/g o /g;
    $yomi =~ s/ザ/z a /g;
    $yomi =~ s/ジェ/j e /g;
    $yomi =~ s/ジ/j i /g;
    $yomi =~ s/ズ/z u /g;
    $yomi =~ s/ゼ/z e /g;
    $yomi =~ s/ゾ/z o /g;
    $yomi =~ s/ダ/d a /g;
    $yomi =~ s/ヂ/j i /g;
    $yomi =~ s/ヅ/z u /g;
    $yomi =~ s/デ/d e /g;
    $yomi =~ s/ド/d o /g;
    $yomi =~ s/バ/b a /g;
    $yomi =~ s/ビ/b i /g;
    $yomi =~ s/ブ/b u /g;
    $yomi =~ s/ベ/b e /g;
    $yomi =~ s/ボ/b o /g;
    $yomi =~ s/パ/p a /g;
    $yomi =~ s/ピ/p i /g;
    $yomi =~ s/プ/p u /g;
    $yomi =~ s/ペ/p e /g;
    $yomi =~ s/ポ/p o /g;
    $yomi =~ s/ア/a /g;
    $yomi =~ s/イ/i /g;
    $yomi =~ s/ウ/u /g;
    $yomi =~ s/エ/e /g;
    $yomi =~ s/オ/o /g;
    $yomi =~ s/ッ/q /g;
    $yomi =~ s/ー/: /g;
    $yomi =~ s/ヴ/b u /g;
    $yomi =~ s/ツ/ts u /g;
    $yomi =~ s/シ/sh i /g;
    $yomi =~ s/チ/ch i /g;

    $yomi =~ s/a : /a: /g;
    $yomi =~ s/i : /i: /g;
    $yomi =~ s/u : /u: /g;
    $yomi =~ s/e : /e: /g;
    $yomi =~ s/o : /o: /g;

    $yomi =~ s/ $//;
    if (!validate_phoneme(\$yomi)) {
        carp "yomi2phoneme: $copy => $yomi\n";
        return 0;
    }
    return $yomi;
}

# convert a phoneme to a pronunciation
#
# @param String a phoneme
# @return String a pronunciation
sub phoneme2yomi {
    (@_ == 1) or croak $!;
    my $phoneme = shift;
    my $copy = $phoneme;

    $phoneme = "$phoneme ";

    $phoneme =~ s/: / ー /g;

    $phoneme =~ s/a: /a : /g;
    $phoneme =~ s/i: /i : /g;
    $phoneme =~ s/u: /u : /g;
    $phoneme =~ s/e: /e : /g;
    $phoneme =~ s/o: /o : /g;

    $phoneme =~ s/w o / ウォ /g;

    # "クォ","シィ","タァ","ナァ","カァ","ネェ" added.
    $phoneme =~ s/i e / イェ /g;
    $phoneme =~ s/ts o / ツォ /g;
    $phoneme =~ s/n i e / ニェ /g;
    $phoneme =~ s/s u i / スィ /g;
    $phoneme =~ s/t e y u / テュ /g;
    $phoneme =~ s/k u o / クォ /g;
    $phoneme =~ s/sh i : / シィ /g;
    $phoneme =~ s/sh i / シ /g;
    $phoneme =~ s/ch i / チ /g;
    $phoneme =~ s/t a a / タァ /g;
    $phoneme =~ s/n a a / ナァ /g;
    $phoneme =~ s/k a a / カァ /g;
    $phoneme =~ s/n e e / ネェ /g;

    $phoneme =~ s/ts a / ツァ /g;
    $phoneme =~ s/ts i / ツィ /g;
    $phoneme =~ s/ts u / ツ /g;
    $phoneme =~ s/ts e / ツェ /g;
    $phoneme =~ s/ky a / キャ /g;
    $phoneme =~ s/ky u / キュ /g;
    $phoneme =~ s/ky o / キョ /g;
    $phoneme =~ s/sh a / シャ /g;
    $phoneme =~ s/sh u / シュ /g;
    $phoneme =~ s/sh e / シェ /g;
    $phoneme =~ s/sh o / ショ /g;
    $phoneme =~ s/ch a / チァ /g;
    $phoneme =~ s/ch a / チャ /g;
    $phoneme =~ s/ch u / チュ /g;
    $phoneme =~ s/ch e / チェ /g;
    $phoneme =~ s/ch o / チョ /g;
    $phoneme =~ s/ny a / ニャ /g;
    $phoneme =~ s/ny u / ニュ /g;
    $phoneme =~ s/ny o / ニョ /g;
    $phoneme =~ s/hy a / ヒャ /g;
# $phoneme =~ s/hy u / フュ /g;
    $phoneme =~ s/hy u / ヒュ /g;
# $phoneme =~ s/hy o / フョ /g;
    $phoneme =~ s/hy o / ヒョ /g;
    $phoneme =~ s/my a / ミャ /g;
    $phoneme =~ s/my u / ミュ /g;
    $phoneme =~ s/my o / ミョ /g;
    $phoneme =~ s/ry a / リャ /g;
    $phoneme =~ s/ry u / リュ /g;
    $phoneme =~ s/ry o / リョ /g;
    $phoneme =~ s/gy a / ギャ /g;
    $phoneme =~ s/gy u / ギュ /g;
    $phoneme =~ s/gy o / ギョ /g;
    $phoneme =~ s/by a / ビャ /g;
    $phoneme =~ s/by u / ビュ /g;
    $phoneme =~ s/by o / ビョ /g;
    $phoneme =~ s/dy u / ヂュ /g;
    $phoneme =~ s/dy o / ヂョ /g;
    $phoneme =~ s/py a / ピャ /g;
    $phoneme =~ s/py u / ピュ /g;
    $phoneme =~ s/py o / ピョ /g;
    $phoneme =~ s/t i / ティ /g;
    $phoneme =~ s/f a / ファ /g;
    $phoneme =~ s/f i / フィ /g;
    $phoneme =~ s/f e / フェ /g;
    $phoneme =~ s/f o / フォ /g;
# $phoneme =~ s/j a / ジァ /g;
    $phoneme =~ s/j a / ジャ /g;
    $phoneme =~ s/j u / ジュ /g;
    $phoneme =~ s/j o / ジョ /g;
    $phoneme =~ s/d i / ディ /g;
# $phoneme =~ s/d u / ドゥ /g;
    $phoneme =~ s/d u / デュ /g;
    $phoneme =~ s/w e / ウェ /g;
    $phoneme =~ s/w i / ウィ /g;
# $phoneme =~ s/k a / クヮ /g;
    $phoneme =~ s/k a / カ /g;
    $phoneme =~ s/k i / キ /g;
    $phoneme =~ s/k u / ク /g;
    $phoneme =~ s/k e / ケ /g;
    $phoneme =~ s/k o / コ /g;
    $phoneme =~ s/s a / サ /g;
    $phoneme =~ s/s u / ス /g;
    $phoneme =~ s/s e / セ /g;
    $phoneme =~ s/s o / ソ /g;
    $phoneme =~ s/t a / タ /g;
    $phoneme =~ s/t u / トゥ /g;
    $phoneme =~ s/t e / テ /g;
    $phoneme =~ s/t o / ト /g;
    $phoneme =~ s/n a / ナ /g;
    $phoneme =~ s/n i / ニ /g;
    $phoneme =~ s/n u / ヌ /g;
    $phoneme =~ s/n e / ネ /g;
    $phoneme =~ s/n o / ノ /g;
    $phoneme =~ s/h a / ハ /g;
    $phoneme =~ s/h i / ヒ /g;
    $phoneme =~ s/f u / フ /g;
# $phoneme =~ s/h e / ヒェ /g;
    $phoneme =~ s/h e / ヘ /g;
    $phoneme =~ s/h o / ホ /g;
    $phoneme =~ s/m a / マ /g;
    $phoneme =~ s/m i / ミ /g;
    $phoneme =~ s/m u / ム /g;
# $phoneme =~ s/m e / ミェ /g;
    $phoneme =~ s/m e / メ /g;
    $phoneme =~ s/m o / モ /g;
    $phoneme =~ s/y a / ヤ /g;
    $phoneme =~ s/y u / ユ /g;
    $phoneme =~ s/y o / ヨ /g;
    $phoneme =~ s/r a / ラ /g;
    $phoneme =~ s/r i / リ /g;
    $phoneme =~ s/r u / ル /g;
    $phoneme =~ s/r e / レ /g;
    $phoneme =~ s/r o / ロ /g;
    $phoneme =~ s/w a / ワ /g;
    $phoneme =~ s/N / ン /g;
# $phoneme =~ s/g a / グヮ /g;
    $phoneme =~ s/g a / ガ /g;
    $phoneme =~ s/g i / ギ /g;
    $phoneme =~ s/g u / グ /g;
    $phoneme =~ s/g e / ゲ /g;
    $phoneme =~ s/g o / ゴ /g;
    $phoneme =~ s/z a / ザ /g;
    $phoneme =~ s/j e / ジェ /g;
# $phoneme =~ s/j i / ズィ /g;
    $phoneme =~ s/j i / ジ /g;
    $phoneme =~ s/z u / ズ /g;
    $phoneme =~ s/z e / ゼ /g;
    $phoneme =~ s/z o / ゾ /g;
    $phoneme =~ s/d a / ダ /g;
    $phoneme =~ s/j i / ヂ /g;
    $phoneme =~ s/z u / ヅ /g;
    $phoneme =~ s/d e / デ /g;
    $phoneme =~ s/d o / ド /g;
# $phoneme =~ s/b a / ヴァ /g;
    $phoneme =~ s/b a / バ /g;
# $phoneme =~ s/b i / ヴィ /g;
# $phoneme =~ s/b i / ブィ /g;
    $phoneme =~ s/b i / ビ /g;
# $phoneme =~ s/b u / ヴ /g;
    $phoneme =~ s/b u / ブ /g;
# $phoneme =~ s/b e / ヴェ /g;
    $phoneme =~ s/b e / ベ /g;
# $phoneme =~ s/b o / ヴォ /g;
    $phoneme =~ s/b o / ボ /g;
    $phoneme =~ s/p a / パ /g;
    $phoneme =~ s/p i / ピ /g;
    $phoneme =~ s/p u / プ /g;
    $phoneme =~ s/p e / ペ /g;
    $phoneme =~ s/p o / ポ /g;
    $phoneme =~ s/a / ア /g;
    $phoneme =~ s/i / イ /g;
    $phoneme =~ s/u / ウ /g;
    $phoneme =~ s/e / エ /g;
    $phoneme =~ s/o / オ /g;
# 助詞の「ヲ」は単独で現れるだろうから、phoneme2yomi で呼ばれることはない
# $phoneme =~ s/o / ヲ /g;
    $phoneme =~ s/q / ッ /g;
    $phoneme =~ s/: / ー /g;

    if (!validate_yomi(\$phoneme)) {
      carp "phoneme2yomi: $copy => $phoneme\n";
      croak $!;
   }
    $phoneme =~ s/\ +//g;
    return $phoneme;
}

1;
