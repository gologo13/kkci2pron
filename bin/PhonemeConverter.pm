## Class to convert a kkci phoneme to a pronunciation phoneme
#!/usr/bin/env perl
package KKCI2Pron::PhonemeConverter;

use strict;
use warnings;
use encoding 'utf-8';
use Carp;
use IPC::Open2;

our $DEBUG = 0;

# Constructor
#
# @param String a path of a kyfd config.
# @param String a path of a kyfd
sub new {
    my $class = shift;
    (@_ == 2) or die $!;
    my ($config_path, $kyfd_path) = @_;
    die "kyfd must be installed: $!" if (! -x $kyfd_path);
    die "$config_path: $!" if (! -e $config_path);
    open2(my $reader, my $writer, "kyfd $config_path 2>/dev/null");
    my $self = {
        'reader' => $reader,
        'writer' => $writer,
    };
    bless $self, $class;
}

# Convert a kkci phoneme to a pronunciation phoneme
#
# @param String a kkci phoneme
# @return String a pronunciation phoneme
sub convert {
    my ($self) = shift;
    (@_ == 1) or die $!;
    my ($kkci_phoneme) = @_;

    my $writer = $self->{writer};
    my $reader = $self->{reader};

    # get the converted results from kyfd
    print $writer "$$kkci_phoneme\n";
    my $baseform_phoneme = <$reader>;
    chomp($baseform_phoneme);
    $baseform_phoneme = join(' ', map { (split(/\+/))[1] } split(/\s/, $baseform_phoneme));

    # remove underscores where the baseform phoneme contains
    $baseform_phoneme =~ s/\_/\ /g;

    # in case that the phoneme of baseform is emtpy
    $baseform_phoneme = $$kkci_phoneme if ($baseform_phoneme eq '<eps>');

    if ($DEBUG) { warn "$$kkci_phoneme => $baseform_phoneme"; }

    return $baseform_phoneme;
};

1;
