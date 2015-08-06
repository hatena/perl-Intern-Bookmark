package Intern::Bookmark::Config;

use strict;
use warnings;
use utf8;

use Intern::Bookmark::Config::Route;

use Config::ENV 'INTERN_BOOKMARK_ENV', export => 'config';
use Path::Class qw(file);

my $Router = Intern::Bookmark::Config::Route->make_router;
my $Root = file(__FILE__)->dir->parent->parent->parent->absolute;

sub router { $Router }
sub root { $Root }

common {
};

my $server_port = $ENV{SERVER_PORT} || 3000;

config default => {
    'server.port'     => $server_port,
    'origin'          => "http://localhost:${server_port}",
    'file.log.access' => 'log/access_log',
    'file.log.error'  => 'log/error_log',
    'dir.static.root'    => 'static',
    'dir.static.favicon' => 'static/images',

    # HatenaのOAuthアプリケーション登録をして、keyを埋めてください
    # http://developer.hatena.ne.jp/ja/documents/auth/apis/oauth/consumer
    'hatena_oauth.consumer_key'    => 'xxxxxxxxxxxxx',
    'hatena_oauth.consumer_secret' => 'xxxxxxxxxxxxxxxxxxxxxxxxx',
};

config production => {
};

config local => {
    parent('default'),
    db => {
        intern_bookmark => {
            user     => 'nobody',
            password => 'nobody',
            dsn      => 'dbi:mysql:dbname=intern_bookmark;host=localhost',
        },
    },
    db_timezone => 'UTC',
};

config test => {
    parent('default'),

    db => {
        intern_bookmark => {
            user     => 'nobody',
            password => 'nobody',
            dsn      => 'dbi:mysql:dbname=intern_bookmark_test;host=localhost',
        },
    },
    db_timezone => 'UTC',
};

1;
