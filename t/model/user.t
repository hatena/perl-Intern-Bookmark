package t::Intern::Bookmark::Model::User;

use strict;
use warnings;
use utf8;
use lib 't/lib';

use Test::Intern::Bookmark;

use Test::More;

use parent 'Test::Class';

use Intern::Bookmark::Util;

use JSON::XS;

sub _use : Test(startup => 1) {
    my ($self) = @_;
    use_ok 'Intern::Bookmark::Model::User';
}

sub _accessor : Test(3) {
    my $now = Intern::Bookmark::Util::now;
    my $user = Intern::Bookmark::Model::User->new(
        user_id => 1,
        name    => 'user_name',
        created => DateTime::Format::MySQL->format_datetime($now),
    );
    is $user->user_id, 1;
    is $user->name, 'user_name';
    is $user->created->epoch, $now->epoch;
}

sub _json_hash : Test(1) {
    my $now = Intern::Bookmark::Util::now;
    my $user = Intern::Bookmark::Model::User->new(
        user_id => 1,
        name    => 'user_name',
        created => $now,
    );

    my $json = JSON::XS->new;

    my $json_string = $json->encode($user->json_hash);

    is_deeply $json->decode($json_string), {
        user_id => 1,
        name    => 'user_name',
        created => $now.q(),
    };
}

sub _as_flatten_hashref : Test(1) {
    my $now = Intern::Bookmark::Util::now;
    my $user = Intern::Bookmark::Model::User->new(
        user_id => 1,
        name => 'Yuno',
    );

    is_deeply $user->as_flatten_hashref, {
        'user.user_id'         => $user->user_id,
        'user.name'            => 'Yuno',
    };
}

__PACKAGE__->runtests;

1;
