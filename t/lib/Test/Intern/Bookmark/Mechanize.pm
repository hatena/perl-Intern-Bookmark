package Test::Intern::Bookmark::Mechanize;

use strict;
use warnings;
use utf8;

use parent qw(Test::WWW::Mechanize::PSGI);
use Plack::Builder;
use Plack::Session;

use Test::More ();

use Exporter qw(import);
our @EXPORT = qw(create_mech);

use Intern::Bookmark;

my $app = builder {
    enable 'HTTPExceptions';

    Intern::Bookmark->as_psgi;
};

sub create_mech (;%) {
    return __PACKAGE__->new(@_);
}

sub new {
    my ($class, %opts) = @_;

    my $user = delete $opts{user};

    my $user_mw = sub {
        my $app = shift;
        builder {
            enable 'Session';
            sub {
                my $env = shift;
                my $user_name = $user ? $user->name : '';
                my $user_info = { url_name => $user ? $user->name : '' };
                my $session = Plack::Session->new($env);
                $session->set(hatenaoauth_user_info => $user_info);
                $app->($env);
            };
        };
    };

    my $self = $class->SUPER::new(
        app => $user_mw->($app),
        %opts,
    );

    return $self;
}

1;
