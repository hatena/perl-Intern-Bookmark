package Intern::Bookmark::Config::Route;

use strict;
use warnings;
use utf8;

use Intern::Bookmark::Config::Route::Declare;

sub make_router {
    return router {
        connect '/' => {
            engine => 'Index',
            action => 'default',
        };

        connect '/bookmark' => {
            engine => 'Bookmark',
            action => 'default',
        };

        connect '/bookmark/add' => {
            engine => 'Bookmark',
            action => 'add_get',
        } => { method => 'GET' };
        connect '/bookmark/add' => {
            engine => 'Bookmark',
            action => 'add_post',
        } => { method => 'POST' };

        connect '/bookmark/delete' => {
            engine => 'Bookmark',
            action => 'delete_get',
        } => { method => 'GET' };
        connect '/bookmark/delete' => {
            engine => 'Bookmark',
            action => 'delete_post',
        } => { method => 'POST' };

        # API
        connect '/api/bookmarks' => {
            engine => 'API',
            action => 'bookmarks',
        };
        connect '/api/bookmark' => {
            engine => 'API',
            action => 'bookmark_post',
        } => { method => 'POST'};
    };
}

1;
