package t::Intern::Bookmark::Service::Bookmark;

use strict;
use warnings;
use utf8;
use lib 't/lib';

use parent qw(Test::Class);

use Test::Intern::Bookmark;
use Test::Intern::Bookmark::Mechanize;
use Test::Intern::Bookmark::Factory;

use Test::More;
use Test::Deep;
use Test::Exception;

use String::Random qw(random_regex);

use Intern::Bookmark::Context;

sub _require : Test(startup => 1) {
    my ($self) = @_;
    require_ok 'Intern::Bookmark::Service::Bookmark';
}

sub find_bookmark_by_user_and_entry : Test(4) {
    my ($self) = @_;

    my $c = Intern::Bookmark::Context->new;

    my $created_bookmark = create_bookmark;

    my $bookmark = Intern::Bookmark::Service::Bookmark->find_bookmark_by_user_and_entry($c->dbh, {
        user => $created_bookmark->user,
        entry => $created_bookmark->entry,
    });

    isa_ok $bookmark, 'Intern::Bookmark::Model::Bookmark', 'blessされている';
    is $bookmark->user_id, $created_bookmark->user_id, 'user_idが一致する';
    is $bookmark->entry_id, $created_bookmark->entry_id, 'entry_idが一致する';
    is $bookmark->comment, $created_bookmark->comment, 'commentが一致する';
}

sub find_bookmarks_by_user : Test(2) {
    my ($self) = @_;

    my $c = Intern::Bookmark::Context->new;

    subtest '全てのブックマークがほしいとき' => sub {
        my $user = create_user;

        my $bookmark_1 = create_bookmark(user => $user);
        my $bookmark_2 = create_bookmark(user => $user);
        my $other_bookmark = create_bookmark;

        my $bookmarks = Intern::Bookmark::Service::Bookmark->find_bookmarks_by_user($c->dbh, {
            user => $user,
        });

        is scalar @$bookmarks, 2;
        cmp_deeply [map { $_->bookmark_id } @$bookmarks], [$bookmark_1->bookmark_id, $bookmark_2->bookmark_id];
    };

    subtest 'order_by指定するとき' => sub {
        my $user = create_user;

        my $bookmark_1 = create_bookmark(user => $user);
        my $bookmark_2 = create_bookmark(user => $user);
        my $other_bookmark = create_bookmark;

        my $bookmarks = Intern::Bookmark::Service::Bookmark->find_bookmarks_by_user($c->dbh, {
            user => $user,
            order_by => 'created DESC',
        });

        is scalar @$bookmarks, 2;
        cmp_deeply [map { $_->bookmark_id } @$bookmarks], [$bookmark_2->bookmark_id, $bookmark_1->bookmark_id], '順番が逆になっている';
    };

    subtest 'per_pageとpageを指定するとき' => sub {
        my $user = create_user;

        my $bookmark_1 = create_bookmark(user => $user);
        my $bookmark_2 = create_bookmark(user => $user);
        my $other_bookmark = create_bookmark;
        my $bookmark_3 = create_bookmark(user => $user);
        my $bookmark_4 = create_bookmark(user => $user);

        my $bookmarks = Intern::Bookmark::Service::Bookmark->find_bookmarks_by_user($c->dbh, {
            user => $user,
            per_page => 2,
            page => 1,
        });

        is scalar @$bookmarks, 2;
        cmp_deeply [map { $_->bookmark_id } @$bookmarks], [$bookmark_1->bookmark_id, $bookmark_2->bookmark_id], '最初の2件';

        $bookmarks = Intern::Bookmark::Service::Bookmark->find_bookmarks_by_user($c->dbh, {
            user => $user,
            per_page => 2,
            page => 2,
        });

        is scalar @$bookmarks, 2;
        cmp_deeply [map { $_->bookmark_id } @$bookmarks], [$bookmark_3->bookmark_id, $bookmark_4->bookmark_id], '後の2件';
    };
}

sub find_bookmarks_by_entry : Tests(2) {
    my ($self) = @_;

    my $c = Intern::Bookmark::Context->new;

    my $entry = create_entry;

    my $bookmark_1 = create_bookmark(entry => $entry);
    my $bookmark_2 = create_bookmark(entry => $entry);
    my $other_bookmark = create_bookmark;

    my $bookmarks = Intern::Bookmark::Service::Bookmark->find_bookmarks_by_entry($c->dbh, {
        entry => $entry,
    });

    is scalar @$bookmarks, 2;
    cmp_deeply [map { $_->bookmark_id } @$bookmarks], [$bookmark_1->bookmark_id, $bookmark_2->bookmark_id];
}

sub load_entry_info : Test(1) {
    my ($self) = @_;

    my $c = Intern::Bookmark::Context->new;

    my $entry = create_entry;
    my $bookmark = create_bookmark(entry => $entry);
    $bookmark->entry(undef);

    my $bookmarks = Intern::Bookmark::Service::Bookmark->load_entry_info($c->dbh, [$bookmark]);

    cmp_deeply $entry, $bookmarks->[0]->entry;
}

sub load_user : Test(1) {
    my ($self) = @_;

    my $c = Intern::Bookmark::Context->new;

    my $user = create_user;
    my $bookmark = create_bookmark(user => $user);
    $bookmark->user(undef);

    my $bookmarks = Intern::Bookmark::Service::Bookmark->load_user($c->dbh, [$bookmark]);

    cmp_deeply $user, $bookmarks->[0]->user;
}

sub create : Test(4) {
    my ($self) = @_;

    my $user = create_user;
    my $entry = create_entry;

    my $c = Intern::Bookmark::Context->new;

    Intern::Bookmark::Service::Bookmark->create($c->dbh, {
        user_id => $user->user_id,
        entry_id => $entry->entry_id,
        comment => 'Comment',
    });

    my $bookmark = $c->dbh->select_row(q[
        SELECT * FROM bookmark
          WHERE
            user_id  = ? AND entry_id = ?
    ], $user->user_id, $entry->entry_id);

    ok $bookmark;
    is $bookmark->{user_id}, $user->user_id;
    is $bookmark->{entry_id}, $entry->entry_id;
    is $bookmark->{comment}, 'Comment';
}

sub update : Test(4) {
    my ($self) = @_;

    my $bookmark = create_bookmark;

    is $bookmark->updated, $bookmark->created, 'updatedはcreatedと同じ';

    sleep 1;

    my $c = Intern::Bookmark::Context->new;

    Intern::Bookmark::Service::Bookmark->update($c->dbh, {
        bookmark_id => $bookmark->bookmark_id,
        comment => 'Updated Comment',
    });

    my $updated_bookmark = $c->dbh->select_row(q[
        SELECT * FROM bookmark
          WHERE
            bookmark_id  = ?
    ], $bookmark->bookmark_id);

    ok $updated_bookmark;
    is $updated_bookmark->{comment}, 'Updated Comment';
    isnt $updated_bookmark->{updated}, $updated_bookmark->{created}, 'updatedが変わっている';
}

sub delete_bookmark : Test(1) {
    my ($self) = @_;

    my $bookmark = create_bookmark;

    my $c = Intern::Bookmark::Context->new;

    Intern::Bookmark::Service::Bookmark->delete_bookmark($c->dbh, $bookmark);

    my $deleted_bookmark = $c->dbh->select_row(q[
        SELECT * FROM bookmark
          WHERE
            bookmark_id  = ?
    ], $bookmark->bookmark_id);

    ok ! $deleted_bookmark, '消えている';
}

sub add_bookmark : Test(2) {
    my ($self) = @_;

    my $user = create_user;
    my $url = 'http://' . random_regex('\w{15}') . '.com/';

    my $c = Intern::Bookmark::Context->new;

    subtest 'bookmarkが作成される' => sub {
        my $bookmark = Intern::Bookmark::Service::Bookmark->add_bookmark($c->dbh, {
            user    => $user,
            url     => $url,
            comment => 'Comment',
        });

        ok $bookmark;
        is $bookmark->user_id, $user->user_id;
        is $bookmark->entry->url, $url;
        is $bookmark->comment, 'Comment';
    };

    subtest '同じurlをブックマークしたときcommentが更新される' => sub {
        my $bookmark = Intern::Bookmark::Service::Bookmark->add_bookmark($c->dbh, {
            user    => $user,
            url     => $url,
            comment => 'Updated Comment',
        });

        ok $bookmark;
        is $bookmark->user_id, $user->user_id;
        is $bookmark->entry->url, $url;
        is $bookmark->comment, 'Updated Comment';
    };
}

sub delete_bookmark_by_url : Tests {
    my ($self) = @_;

    my $user = create_user;
    my $url = 'http://' . random_regex('\w{15}') . '.com/';
    my $entry = create_entry(url => $url);
    my $bookmark = create_bookmark(user => $user, entry => $entry);

    my $c = Intern::Bookmark::Context->new;

    Intern::Bookmark::Service::Bookmark->delete_bookmark_by_url($c->dbh, {
        user => $user,
        url  => $url,
    });

    my $deleted_bookmark = $c->dbh->select_row(q[
        SELECT * FROM bookmark
          WHERE
            user_id  = ? AND entry_id = ?
    ],  $user->user_id, $entry->entry_id);

    ok ! $deleted_bookmark, '消えている';
}

__PACKAGE__->runtests;

1;
