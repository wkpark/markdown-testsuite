#!/usr/bin/perl

#
# MarkdownTester -- Run tests for Markdown implementations
#
# Copyright (c) 2004 John Gruber
# <http://daringfireball.net/projects/markdown/>
#

use strict;
use warnings;
use Getopt::Long;
use Benchmark;

our $VERSION = '1.0';
# Mon 13 Dec 2004

my $time_start = new Benchmark;
my $test_dir = "Tests";
my $script  = "./Markdown.pl";
my $use_tidy = 0;
my ($flag_version);

GetOptions (
			"script=s"   => \$script,
			"testdir=s"  => \$test_dir,
			"tidy"       => \$use_tidy,
			"version"    => \$flag_version,
			);

if($flag_version) {
	my $progname = $0;
	$progname =~ s{.*/}{};
	die "$progname version $VERSION\n";
}

unless (-d $test_dir) { die "'$test_dir' is not a directory.\n"; }
unless (-f $script)   { die "$script does not exist.\n"; }
unless (-x $script)   { die "$script is not executable.\n"; }

my $tests_passed = 0;
my $tests_failed = 0;

foreach my $testfile (glob "$test_dir/*.md") {
	my $testname = $testfile;
	$testname =~ s{.*/(.+)\.md$}{$1}i; 
	print "$testname ... ";

	# Look for a corresponding .html file for each .md file:
	my $resultfile = $testfile;
	$resultfile =~ s{\.md$}{\.html}i;
	unless (-f $resultfile) {die "'$resultfile' does not exist.\n";}
	
	# open(TEST, $testfile)     || die("Can't open testfile: $!");
	open(RESULT, $resultfile) || die("Can't open resultfile: $!");
	undef $/;
	# my $t_input = <TEST>;
	my $t_result = <RESULT>;

	my $t_output = `$script '$testfile'`;

	# Normalize the output and expected result strings:
	$t_result =~ s/\s+\z//; # trim trailing whitespace
	$t_output =~ s/\s+\z//; # trim trailing whitespace
	if ($use_tidy) {
		#  Escape the strings, pass them through to CLI tidy tool for tag-level equivalency
		$t_result =~ s{'}{'\\''}g; # escape ' chars for shell
		$t_output =~ s{'}{'\\''}g;
		$t_result = `echo '$t_result' | tidy --show-body-only 1 --quiet 1 --show-warnings 0`;
		$t_output = `echo '$t_output' | tidy --show-body-only 1 --quiet 1 --show-warnings 0`;
	}

	if ($t_output eq $t_result) {
		print "OK\n";
		$tests_passed++;
	}
	else {
		print "FAILED\n\n";
		$tests_failed++;
	}
}

print "\n\n";
print "$tests_passed passed; $tests_failed failed.\n";

my $time_end = new Benchmark;
my $time_diff = timediff($time_end, $time_start);
print "Benchmark: ", timestr($time_diff), "\n";


__END__

=pod

=head1 NAME

B<MarkdownTest>


=head1 SYNOPSIS

B<MarkdownTest.pl> [ B<--options> ]  [ I<file> ... ]


=head1 DESCRIPTION


=head1 OPTIONS

Use "--" to end switch parsing. For example, to open a file named "-z", use:

	MarkdownTest.pl -- -z

=over 4

=item B<--script>

Specify the path to the Markdown script to test. Defaults to
"./Markdown.pl". Example:

	./MarkdownTest.pl --script ./PHP-Markdown/php-markdown

=item B<--testdir>

Specify the path to a directory containing test data. Defaults to "Tests".

=item B<--tidy>

Flag to turn on using the command line 'tidy' tool to normalize HTML
output before comparing script output to the expected test result.
Assumes that the 'tidy' command is available in your PATH. Defaults to
off.

=back



=head1 BUGS



=head1 VERSION HISTORY

1.0	Mon 13 Dec 2004



=head1 COPYRIGHT AND LICENSE

Copyright (c) 2004 John Gruber  
<http://daringfireball.net/>   
All rights reserved.

This is free software; you may redistribute it and/or modify it under
the same terms as Perl itself.

=cut
