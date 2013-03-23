#!/usr/bin/env perl
# translate KKCI to pronunciation by using FSTs

use strict;
use warnings;
use encoding 'utf-8';
use feature qw(switch say);
use File::Basename;
use Getopt::Long;
use IPC::Open2;
push(@INC, '.');
use PhonemePron;

# prepare kyfd
my $config = shift || die "Usage: ".basename($0)." config.xml [ -debug ] < input > output\n";
my $DEBUG = 0;
GetOptions('debug' => \$DEBUG);
(-e $config) or die "$config: $!";
my $pid = open2(*Reader, *Writer, "kyfd $config 2>/dev/null");

# declare the concreate translation function
# in this case, translate by using kyfd
my $translate_phoneme_by_fst = sub {
    (@_ == 1) or die $!;
    my ($kkci_phoneme) = @_;

    # get the output from kyfd
    print Writer "$$kkci_phoneme\n";
    my $baseform_phoneme = <Reader>;
    chomp($baseform_phoneme);
    $baseform_phoneme = join(' ', map { (split(/\+/))[1] } split(/\s/, $baseform_phoneme));

    # remove underscores where the baseform phoneme contains
    $baseform_phoneme =~ s/\_/\ /g;

    # in case that the phoneme of baseform is emtpy
    $baseform_phoneme = $$kkci_phoneme if ($baseform_phoneme eq '<eps>');

    if ($DEBUG) { warn "$$kkci_phoneme => $baseform_phoneme"; }

    return $baseform_phoneme;
};
$PhonemePron::translate_phoneme_proto = $translate_phoneme_by_fst;
$PhonemePron::DEBUG = $DEBUG;

# main loop
while (<STDIN>) {
    chomp;
    my @ret;
    for (split(/\ /)) {
        my ($word, $kkci) = split(/\//);
        my $elem;
        given ("$word/$kkci") {
            # 助詞: 「は」、「へ」、「を」
            when ('は/ハ') { $elem = "は/ワ"; }
            when ('へ/ヘ') { $elem = "へ/エ"; }
            when ('を/ヲ') { $elem = "を/オ"; }
            default {
                given ($kkci) {
                    when (["、", "，"]) { $elem = "$word/$kkci"; }
                    when (["。", "．"]) { $elem = "$word/$kkci"; }
                    default {
                        if ($DEBUG) { warn "word=$word, kkci=$kkci"; }
                        my $pron = $PhonemePron::kkci2pron->(\$kkci);
                        $elem = "$word/$pron";
                    }
                }
            }
        }
        push(@ret, $elem);
    }
    print join(" ", @ret),"\n";
}

exit(0);
