package t::Intern::Bookmark::DBI::Factory;
use strict;
use warnings;
use utf8;

use lib 't/lib';

use parent 'Test::Class';

use Test::More;

use Test::Intern::Bookmark;

use Intern::Bookmark::Context;
use Intern::Bookmark::Util;

sub _use : Test(1) {
    use_ok 'Intern::Bookmark::Context';
}

sub _db_config : Test(3) {
    my $factory = Intern::Bookmark::Context->new;
    my $db_config = $factory->db_config('intern_bookmark');
    is $db_config->{user}, 'nobody';
    is $db_config->{password}, 'nobody';
    is $db_config->{dsn}, 'dbi:mysql:dbname=intern_bookmark_test;host=localhost';
}

sub _dbh : Test(1) {
    my $factory = Intern::Bookmark::Context->new;
    my $dbh = $factory->dbh;
    ok $dbh;

}

sub _query_builder : Test(1) {
    my $builder = Intern::Bookmark::Util::query_builder;
    ok $builder;
}

__PACKAGE__->runtests;

1;
