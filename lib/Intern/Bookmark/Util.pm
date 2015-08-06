package Intern::Bookmark::Util;

use strict;
use warnings;
use utf8;

use DateTime;
use DateTime::Format::MySQL;

use Intern::Bookmark::Config;

sub now () {
    my $now = DateTime->now(time_zone => config->param('db_timezone'));
    $now->set_formatter( DateTime::Format::MySQL->new );
    $now;
}

sub datetime_from_db ($) {
    my $dt = DateTime::Format::MySQL->parse_datetime( shift );
    $dt->set_time_zone(config->param('db_timezone'));
    $dt->set_formatter( DateTime::Format::MySQL->new );
    $dt;
}

sub query_builder {
    my ($self) = @_;

    require SQL::Maker;

    my $builder = SQL::Maker->new(
        driver => 'mysql',
    );
    return $builder;
}

1;
__END__
