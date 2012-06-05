#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Net::oFono' ) || print "Bail out!\n";
}

diag( "Testing Net::oFono $Net::oFono::VERSION, Perl $], $^X" );
