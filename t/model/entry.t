package t::Intern::Bookmark::Model::Entry;

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

use JSON::XS;

sub _require : Test(startup => 1) {
    my ($self) = @_;
    require_ok 'Intern::Bookmark::Model::Entry';
}

sub _accessor : Test(5) {
    my $now = Intern::Bookmark::Util::now;
    my $entry = Intern::Bookmark::Model::Entry->new(
        entry_id => 1,
        url      => 'http://www.google.com/',
        title    => 'Google',
        created  => $now,
        updated  => $now,
    );
    is $entry->entry_id, 1;
    is $entry->url, 'http://www.google.com/';
    is $entry->title, 'Google';
    is $entry->created->epoch, $now->epoch;
    is $entry->updated->epoch, $now->epoch;
}

sub _json_hash : Test(1) {
    my $now = Intern::Bookmark::Util::now;
    my $entry = Intern::Bookmark::Model::Entry->new(
        entry_id => 1,
        url      => 'http://www.google.com/',
        title    => 'Google',
        created  => $now,
        updated  => $now,
    );

    my $json = JSON::XS->new;

    my $json_string = $json->encode($entry->json_hash);

    is_deeply $json->decode($json_string), {
        entry_id => 1,
        url      => 'http://www.google.com/',
        title    => 'Google',
        created  => $now.q(),
        updated  => $now.q(),
    };
}

sub _as_flatten_hashref : Test(1) {
    my $now = Intern::Bookmark::Util::now;
    my $entry = Intern::Bookmark::Model::Entry->new(
        entry_id => 1,
        url      => 'http://example.com/',
        title    => 'Example',
        created  => $now.q(),
        updated  => $now.q(),
    );

    is_deeply $entry->as_flatten_hashref, {
        'entry.entry_id'       => $entry->entry_id,
        'entry.url'            => 'http://example.com/',
        'entry.title'          => 'Example',
        'entry.created'        => $now.q(),
        'entry.updated'        => $now.q(),
    };
}

__PACKAGE__->runtests;

1;
