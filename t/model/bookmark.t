package t::Intern::Bookmark::Model::Bookmark;

use strict;
use warnings;
use utf8;
use lib 't/lib';

use parent qw(Test::Class);

use Test::Intern::Bookmark;
use Test::Intern::Bookmark::Mechanize;
use Test::Intern::Bookmark::Factory;

use Test::More;

use Intern::Bookmark::Util;
use Intern::Bookmark::Model::Entry;
use Intern::Bookmark::Model::User;

use Encode;

use JSON::XS;

sub _require : Test(startup => 1) {
    my ($self) = @_;
    require_ok 'Intern::Bookmark::Model::Bookmark';
}

sub _accessor : Test(6) {
    my $now = Intern::Bookmark::Util::now;
    my $bookmark = Intern::Bookmark::Model::Bookmark->new(
        bookmark_id => 1,
        user_id     => 1,
        comment     => 'Commented',
        created     => $now,
        updated     => $now,
    );
    is $bookmark->bookmark_id, 1;
    is $bookmark->bookmark_id, 1;
    is $bookmark->user_id, 1;
    is $bookmark->comment, 'Commented';
    is $bookmark->created->epoch, $now->epoch;
    is $bookmark->updated->epoch, $now->epoch;
}

sub _json_hash : Test(1) {
    my $now = Intern::Bookmark::Util::now;
    my $bookmark = Intern::Bookmark::Model::Bookmark->new(
        bookmark_id => 1,
        user_id     => 1,
        comment     => encode_utf8 'コメント',
        created     => $now,
        updated     => $now,
    );
    my $entry = Intern::Bookmark::Model::Entry->new(
        entry_id => 1,
        url      => 'http://www.google.com/',
        title    => 'Google',
        created  => $now,
        updated  => $now,
    );
    $bookmark->entry($entry);
    my $user = Intern::Bookmark::Model::User->new(
        user_id => 1,
        name    => 'user_name',
        created => $now,
    );
    $bookmark->user($user);

    my $json = JSON::XS->new;

    my $json_string = $json->encode($bookmark->json_hash);

    is_deeply $json->decode($json_string), {
        bookmark_id => 1,
        comment     => 'コメント',
        created     => $now.q(),
        updated     => $now.q(),
        user        => {
            user_id => 1,
            name    => 'user_name',
            created => $now.q(),
        },
        entry       => {
            entry_id => 1,
            url      => 'http://www.google.com/',
            title    => 'Google',
            created  => $now.q(),
            updated  => $now.q(),
        },
    };
}

sub _as_flatten_hashref : Test(1) {
    my $now = Intern::Bookmark::Util::now;
    my $user = Intern::Bookmark::Model::User->new(
        user_id => 1,
        name    => 'Yuno',
    );
    my $entry = Intern::Bookmark::Model::Entry->new(
        entry_id => 1,
        url      => 'http://example.com/',
        title    => 'Example',
        created  => $now.q(),
        updated  => $now.q(),
    );
    my $bookmark = Intern::Bookmark::Model::Bookmark->new(
        user_id  => $user->user_id,
        user     => $user,
        entry_id => $entry->entry_id,
        entry    => $entry,
        comment  => encode_utf8('こんにちは, かわいいページですね'),
        created  => $now.q(),
        updated  => $now.q(),
    );

    is_deeply $bookmark->as_flatten_hashref, {
        'bookmark.bookmark_id' => $bookmark->bookmark_id,
        'bookmark.comment'     => 'こんにちは, かわいいページですね',
        'bookmark.created'     => $now.q(),
        'bookmark.updated'     => $now.q(),
        'entry.entry_id'       => $entry->entry_id,
        'entry.url'            => 'http://example.com/',
        'entry.title'          => 'Example',
        'entry.created'        => $now.q(),
        'entry.updated'        => $now.q(),
        'user.user_id'         => $user->user_id,
        'user.name'            => 'Yuno',
    };
}

__PACKAGE__->runtests;

1;
