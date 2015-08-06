requires 'LWP::UserAgent';
requires 'LWP::Protocol::https';
requires 'Plack::Middleware::Session';
requires 'SQL::Maker';
requires 'JSON::Types';

# ---- for framework ---
requires 'Carp';
requires 'JSON::XS';
requires 'Class::Accessor::Lite';
requires 'Class::Accessor::Lite::Lazy';
requires 'Class::Load';
requires 'Config::ENV';
requires 'Encode';
requires 'HTTP::Status';
requires 'HTTP::Throwable';
requires 'Hash::MultiValue';
requires 'Path::Class';
requires 'Router::Simple';
requires 'Text::Xslate';
requires 'Text::Xslate::Bridge::TT2Like';
requires 'URI';
requires 'URI::QueryParam';
requires 'FormValidator::Lite';

requires 'DateTime';
requires 'DateTime::Format::MySQL';

requires 'Proclet';
requires 'Plack';
requires 'Plack::Middleware::StackTrace::RethrowFriendly';
requires 'Plack::Middleware::HatenaOAuth';

# ---- for DB ----
requires 'DBIx::Sunny';
requires 'DBD::mysql';

# ---- for server ----
requires 'Starlet';

requires 'Devel::KYTProf';

# ---- for test ----
on test => sub {
    requires 'Test::More';
    requires 'Test::Class';
    requires 'Test::WWW::Mechanize::PSGI';
    requires 'Test::MockTime::HiRes';
    requires 'String::Random';
    requires 'DBIx::RewriteDSN';
    requires 'Test::Mock::Guard';
};
