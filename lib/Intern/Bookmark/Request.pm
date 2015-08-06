package Intern::Bookmark::Request;

use strict;
use warnings;
use utf8;

use parent 'Plack::Request';

use Hash::MultiValue;
use Encode qw(decode_utf8);

sub parameters {
    my $self = shift;

    $self->env->{'plack.request.merged'} ||= do {
        my $query = $self->query_parameters;
        my $body  = $self->body_parameters;
        my $path  = $self->path_parameters;
        Hash::MultiValue->new($path->flatten, $query->flatten, $body->flatten);
    };
}

sub path_parameters {
    my $self = shift;
    if (@_ > 1) {
        $self->{_path_parameters} = Hash::MultiValue->new(@_);
        delete $self->env->{'plack.request.merged'}; # remove instance cache
    }
    return $self->{_path_parameters} ||= Hash::MultiValue->new;
}

sub string_param {
    my ($self, $key) = @_;
    return decode_utf8 $self->parameters->{$key};
}

sub number_param {
    my ($self, $key) = @_;
    my $val = $self->parameters->{$key} // 0;
    return $val + 0;
}

sub is_xhr {
    my $self = shift;
    return ( $self->header('X-Requested-With') || '' ) eq 'XMLHttpRequest';
}

1;
