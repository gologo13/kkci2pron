#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use FindBin;
use lib "$FindBin::Bin";
use WordkkciConverter;
use KKCIConverter;
use PhonemeConverter;

my $KYFD_PATH = "/usr/local/bin/kyfd";
my $DEBUG = 0;

my $CONFIG_PATH = shift || usage();
GetOptions('debug' => \$DEBUG);

$KKCI2Pron::PhonemeConverter::DEBUG = $DEBUG;
$KKCI2Pron::KKCIConverter::DEBUG = $DEBUG;
$KKCI2Pron::WordkkciConverter::DEBUG = $DEBUG;

my $pConverter = KKCI2Pron::PhonemeConverter->new($CONFIG_PATH, $KYFD_PATH);
my $kConverter = KKCI2Pron::KKCIConverter->new($pConverter);
my $wConverter = KKCI2Pron::WordkkciConverter->new($kConverter);

while (<STDIN>) {
    chomp;
    my @ret;
    for (split(/\ /)) {
        my ($word, $kkci) = split(/\//);
        my $elem = $wConverter->convert($word, $kkci);
        push(@ret, $elem);
    }
    print join(" ", @ret),"\n";
}

exit(0);

sub usage {
    die "Usage: ".basename($0)." config.xml [ -debug ] < input > output";
}
