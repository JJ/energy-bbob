#!/usr/bin/env perl
#-------------------------------------------------------------------
# t/utils.t — tests for lib/Utils.pm
#-------------------------------------------------------------------

use strict;
use warnings;

use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Utils qw(process_pinpoint_output mini_slurp);

#-------------------------------------------------------------------
# process_pinpoint_output
#-------------------------------------------------------------------

subtest 'process_pinpoint_output — normal output' => sub {
    # Simulate two energy readings followed by an elapsed-time line.
    my $output = "GPU Energy: 1.23 J\nPKG Energy: 4.56 J\nElapsed: 7.89 seconds\n";
    my ($gpu, $pkg, $seconds) = process_pinpoint_output($output);
    is($gpu,     '1.23', 'GPU energy parsed correctly');
    is($pkg,     '4.56', 'PKG energy parsed correctly');
    is($seconds, '7.89', 'elapsed seconds parsed correctly');
};

subtest 'process_pinpoint_output — zero joules returns (0,0,0)' => sub {
    my $output = "GPU Energy: 0.00 J\nPKG Energy: 4.56 J\nElapsed: 7.89 seconds\n";
    my ($gpu, $pkg, $seconds) = process_pinpoint_output($output);
    is($gpu,     0, 'GPU is 0 when 0.00 J present');
    is($pkg,     0, 'PKG is 0 when 0.00 J present');
    is($seconds, 0, 'seconds is 0 when 0.00 J present');
};

subtest 'process_pinpoint_output — multiple decimal places' => sub {
    my $output = "12.345 J GPU\n67.890 J PKG\n10.001 seconds\n";
    my ($gpu, $pkg, $seconds) = process_pinpoint_output($output);
    is($gpu,     '12.345', 'GPU with more decimal places');
    is($pkg,     '67.890', 'PKG with more decimal places');
    is($seconds, '10.001', 'seconds with more decimal places');
};

#-------------------------------------------------------------------
# mini_slurp
#-------------------------------------------------------------------

subtest 'mini_slurp — reads entire file contents' => sub {
    require File::Temp;
    my $tmpfh = File::Temp->new(UNLINK => 1, SUFFIX => '.txt');
    my $tmpfile = $tmpfh->filename;
    my $content = "line one\nline two\nline three\n";

    print $tmpfh $content;
    $tmpfh->flush;

    my $result = mini_slurp($tmpfile);
    is($result, $content, 'mini_slurp returns complete file content');
};

#-------------------------------------------------------------------

done_testing();
