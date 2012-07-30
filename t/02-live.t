use strict;
use warnings;
use Test::More;
use Try::Tiny;

# Make sure prerequisites are there

BEGIN {
    use_ok('Net::SSL');
    use_ok('LWP::UserAgent');
    use_ok('LWP::Protocol::https');
    use_ok('HTTP::Request');
}

use constant URL => 'https://rt.cpan.org/';
use constant PROXY_ADDR_PORT => 'localhost:3128';

unless ($ENV{CRYPT_SSLEAY_NO_LIVE_TEST}) {
    test_connect_through_proxy(PROXY_ADDR_PORT);
    test_connect(URL);
}
else {
    diag("Network tests disabled");
}

done_testing;

sub test_connect_through_proxy {
    my ($proxy) = @_;

    my $test_name = 'connect through proxy';
    Net::SSL::send_useragent_to_proxy(0);

    my $no_proxy;

    try {
        live_connect({ chobb => 'schoenmaker'});
    }
    catch {
        if (/^proxy connect failed: proxy connect to $proxy failed: /) {
            pass("$test_name - no proxy available");
        }
        else {
            fail("$test_name - untrapped error");
            diag($_);
        }
        $no_proxy = 1;
    };

    pass($test_name);

    SKIP: {
        if ($no_proxy) {
            skip(sprintf('no proxy found at %s', PROXY_ADDR_PORT), 1);
        }

        Net::SSL::send_useragent_to_proxy(1);

        try {
            live_connect( {chobb => 'schoenmaker'} );
        }
        catch {
            TODO: {
                local $TODO = "caller stack walk broken (CPAN bug #4759)";
                is($_, '', "can forward useragent string to proxy");
            }
        };
    }

    return;
}

sub test_connect {
    my ($url) = @_;

    diag('[RT #73755] Cheat by disabling LWP::UserAgent host verification');

    my $ua  = LWP::UserAgent->new(
        agent => "Crypt-SSLeay $Crypt::SSLeay::VERSION tester",
        ssl_opts => { verify_hostname => 0 },
    );

    my $req = HTTP::Request->new;

    $req->method('HEAD');
    $req->uri($url);

    my $test_name = 'HEAD https://rt.cpan.org/';
    my $res;

    try {
        $res = $ua->request($req);
    }
    catch {
        fail($test_name);
        diag("Error: '$_'");
    };

    if ($res->is_success) {
        pass($test_name);
    }
    else {
        fail($test_name);
        diag("HTTP status = ", $res->status_line);
        diag("This may not be the fault of the module, $url may be down");
    }

    return;
}

sub live_connect {
    my $hr = shift;

    local $ENV{HTTPS_PROXY} = PROXY_ADDR_PORT;

    my $socket = Net::SSL->new(
        PeerAddr => 'rt.cpan.org',
        PeerPort => 443,
        Timeout  => 10,
    );

    return defined $socket;
}

