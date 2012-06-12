use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
                module_name       => 'Net::Radio::oFono',
                license           => 'perl',
                dist_author       => q{Jens Rehsack <rehsack@cpan.org>},
                dist_version_from => 'lib/Net/Radio/oFono.pm',
                build_requires    => { 'Test::More' => '0.90', },
                requires          => {
                              'perl'              => 5.010,
                              'Hash::MoreUtils'   => '0.02',
                              'List::MoreUtils'   => '0.22',
                              'List::Util'        => 0,
                              'Log::Any'          => '0.10',
                              'Log::Any::Adapter' => 0,
                              'Net::DBus'         => '1.0.0',
                              'Params::Util'      => '0.37',
                              'Scalar::Util'      => 0,
                            },
                meta_merge => {
                    no_index  => { namespace => [qw(Net::Radio::oFono::Helpers)], },
                    resources => {
                        licenses   => ['http://dev.perl.org/licenses/'],
                        homepage   => 'http://www.ofono.org/',
                        bugtracker => {
                            web => 'http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-Radio-oFono',
                            mailto => 'bug-net-radio-ofono at rt.cpan.org',
                        },
                        repository => {
                                        url  => 'git://repo.or.cz/...',
                                        web  => 'http://repo.or.cz/...',
                                        type => 'git',
                                      },
                                 }
                              },
                add_to_cleanup     => ['Net-oFono-*'],
                create_makefile_pl => 'traditional',
);

$builder->create_build_script();
