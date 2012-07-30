use strict; use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => 'Crypt::SSLeay',

    AUTHOR        => [ # starting with current maintainer
        'A. Sinan Unur <nanis@cpan.org>',
        'David Landgren',
        'Joshua Chamas',
        'Gisle Aas',
    ],

    ABSTRACT_FROM => 'SSLeay.pm',

    VERSION_FROM => 'SSLeay.pm',

    LIBS => '-lz -lssl -lcrypto -lssl32 -lssleay32 -leay32',

    BUILD_REQUIRES => {
        'Try::Tiny' => '0.09',
        'Test::More' => '0.88',
    },

    PREREQ_PM     => {
        'LWP::Protocol::https' => '6.02',
        'MIME::Base64' => 0, # for Net::SSL
    },

    do {
        (my $v = $ExtUtils::MakeMaker::VERSION) =~ tr/_//d; $v
    } > 6.3 ? (LICENSE => 'artistic_2') : (),

);

