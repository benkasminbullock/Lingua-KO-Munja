#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Data::Kanji::Kanjidic ':all';
use Lingua::KO::Munja ':all';
binmode STDOUT, ":utf8";
my $k = parse_kanjidic ('/home/ben/data/edrdg/kanjidic');
my @o = kanjidic_order ($k);
my $max = 100;
for my $kanji (@o[0..$max]) {
    my $entry = $k->{$kanji};
    my $korean = $entry->{W};
    if (! $korean) {
	next;
    }
    for my $w (@$korean) {
	my $hangul = roman2hangul ($w);
	print "$kanji $hangul\n";
    }
}
