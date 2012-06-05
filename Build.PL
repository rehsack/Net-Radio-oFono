use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Net::oFono',
    license             => 'perl',
    dist_author         => q{Jens Rehsack <rehsack@cpan.org>},
    dist_version_from   => 'lib/Net/oFono.pm',
    build_requires => {
                        'Test::More'         => '0.90',
    },
    requires => {
                  'perl'              => 5.010,
                  'Net::DBus'         => '1.0.0',
                  'Params::Util'      => '0.37',
    },
    add_to_cleanup      => [ 'Net-oFono-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
