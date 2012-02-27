# vim:set ft=perl:
use strict;
use warnings;
use lib glob 'modules/*/lib';
use lib 'lib';


use UNIVERSAL::require;
use Path::Class;
use Plack::Builder;
use Cache::MemoryCache;
use LWP::Simple qw($ua);

my $namespace = 'Diary';
$namespace->use or die $@;

my $root = file(__FILE__)->parent->parent;

$ENV{GATEWAY_INTERFACE} = 1; ### disable plack's accesslog
$ENV{PLACK_ENV} = ($ENV{RIDGE_ENV} =~ /production|staging/) ? 'production' : 'development';

builder {
    unless ($ENV{PLACK_ENV} eq 'production') {
        enable "Plack::Middleware::Debug";
        enable "Plack::Middleware::Static",
            path => qr{^/(images|js|css)/},
            root => $root->subdir('static');
    }

    enable "Plack::Middleware::ReverseProxy";

	enable 'Plack::Middleware::Session::Cookie';
	
	enable 'Plack::Middleware::HatenaOAuth',
	    consumer_key       => 'vUarxVrr0NHiTg==',
	    consumer_secret    => 'RqbbFaPN2ubYqL/+0F5gKUe7dHc=',
	    login_path         => '/login_hatena',
        ua                 => $ua;
	
	enable 'Plack::Middleware::TwitterOAuth',
	    consumer_key       => 'F3khxwmfD6xW9C8JAGA',
        consumer_secret    => 'I2ma3elmHLLdkMGMx0JPKslHTowLh5R3xJfzenIKmg',
        login_path         => '/login_twitter',
        ua                 => $ua;
	
    sub {
        my $env = shift;
        $namespace->process($env, {
            root => $root,
        });
    }
};

