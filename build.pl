#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Getopt::Long;
use Perl::Build;
perl_build (
    make_pod => './make-pod.pl',
);
