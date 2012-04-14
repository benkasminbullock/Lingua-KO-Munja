package Lingua::KO::Munja;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw/roman2hangul hangul2roman/;
use warnings;
use strict;
our $VERSION = 0.02;
use Convert::Moji 'make_regex';

my $verbose;

sub makearegex
{
my @possibles = @_;
@possibles = map {$_ =~ s/^-$//; $_} @possibles;
make_regex (@possibles);
}

my @initial = qw(
    g   kk  n   d   tt  r   m   b   pp  s   ss  -   j   jj
    ch  k   t   p   h
);



my $initial_re = makearegex (@initial);

print "@initial\n";

my %initial = a2h (@initial);

my @peak = qw(
    a   ae  ya  yae eo  e   yeo ye  o   wa  wae oe  yo  u
    wo  we  wi  yu  eu  ui  i
);

my $peak_re = makearegex (@peak);

my %peak = a2h (@peak);

my @final = qw(
    -   g   kk  ks  n   nj  nh  d   r   lg  lm  lb  ls  lt
    lp  lh  m   b   ps  s   ss  ng  j   c   k   t   p   h
);

my $final_re = makearegex (@final);

my %final = a2h (@final);

sub hangul
{
    my ($initial, $peak, $final) = @_;
    for ($initial, $peak, $final) {
        if (! $_) {
            $_ = '-';
        }
    }
    if ($verbose) {
    print "Initial = $initial, peak = $peak, final = $final\n";
    print "Initial = $initial{$initial}, peak = $peak{$peak}, final = $final{$final}\n";
}
    my $x = (($initial{$initial} * 21) + $peak{$peak}) * 28 + $final{$final};
    my $hangul = chr (0xAC00 + $x);
    return $hangul;
}

sub roman2hangul
{
    my ($input) = @_;
    my $match = "$initial_re$peak_re$final_re";
    $match =~ s/\\-//g;
    while ($input =~ s/((?:$match)+)/ROMAN/) {
        my $i = $1;
        if ($verbose) {
            print "Looking at '$i' from '$input'.\n";
        }
        my @syllables;
        while ($i =~ s/($match)$//g) {
            if ($verbose) {
                print "pushing $1\n";
            }
            unshift @syllables, $1;
        }
        my @hangul;
        for my $s (@syllables) {
            my $h = $s;
            $h =~ s/^$match$/hangul ($1, $2, $3)/ge;
            push @hangul, $h;
        }
        my $output = join '', @hangul;
        $input =~ s/ROMAN/$output/;
    }
    return $input;
}

sub a2h {
    my @array = @_;
    my %hash;
    my $count = 0;
    for my $k (@array) {
        $hash{$k} = $count;
        $count++;
    }
    return %hash;
}

sub romanize
{
    my ($char) = @_;
    my $han = ord ($char) - 0xAC00;
    my $init = int ($han / (21 * 28));
    my $peak = int ($han / 28) % 21;
    my $final = $han % 28;
    my $roman = join '', $initial[$init], $peak[$peak], $final[$final];
    return $roman;
}

sub hangul2roman
{
    my ($hangul) = @_;
#    print "$hangul\n";
    $hangul =~ s/(\p{Hangul})/romanize ($1)/ge;
    $hangul =~ s/-//g;
#    print "$hangul\n";
    return $hangul;
}

1;

__END__

=encoding utf-8

=head1 NAME

Lingua::KO::Munja - Korean letter conversion

=head1 SYNOPSIS

    use Lingua::KO::Munja qw/roman2hangul hangul2roman/;
    my $roman = hangul2roman ('유사쿠');
    my $hangul = roman2hangul ('yusaku');

=head1 DESCRIPTION

Inputs and outputs are in Perl's Unicode formulation.

This is a companion of L<Lingua::JA::Moji>.

=head1 FUNCTIONS

=head2 roman2hangul

    my $hangul = roman2hangul ('munja');

Convert romanized Korean to hangul.

=head2 hangul2roman

    my $roman = hangul2roman ('문자');

Convert hangul to romanized Korean.

=head1 BUGS

=over

=item Module author knows nothing about Korean

=back

=head1 AUTHOR

Ben Bullock, <bkb@cpan.org>

=head1 COPYRIGHT

Portions of this are taken from L<Lingua::KO::Romanize::Hangul>,
version 0.20, by Yusuke Kawasaki, Copyright (c) 1998-2008 Yusuke
Kawasaki.

The rest is by Ben Bullock.

This program may be copied, used, modified and redistributed under the
same terms as Perl itself.

