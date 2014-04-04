package Amazon::SendToKindle::LegacyPerl;
use 5.008005;
use strict;
use warnings;
use Carp;
use Smart::Args;
use MIME::Entity;
use IO::Socket::SSL qw/inet4/; # global option
use Email::Send;
use Email::Send::Gmail;
use Email::MIME;
use Email::MIME::Creator;
use IO::All;
use Class::Accessor::Lite ( rw => [qw/ subject from to filename filepath /]);

our $VERSION = "0.01";

sub new {
    args(
        my $class,
        my $subject  => { default => 'no-title' },
        my $from     => 'Str',
        my $to       => 'Str',
        my $filename => 'Str',
        my $filepath => 'Str',
    );

    bless {
        subject => $subject,
        from => $from,
        to => $to,
        filename => $filename,
        filepath => $filepath,
    } => $class;
}

sub create_default_body {
    my $self = shift;
    Email::MIME->create(
        attributes => {
            content_type => 'text/plain',
        },
        body_str => 'sample',
    );
}

sub create_attachment_part {
    my $self = shift;
    Email::MIME->create(
        attributes => {
            filename     => $self->filename,
            disposition  => "attachment",
            encoding     => 'base64',
            content_type => 'application/octet-stream',
        },
        body => io( $self->filepath )->all,
    );
}

sub create_email {
    my $self = shift;
    Email::MIME->create(
        header => [
            From    => $self->from,
            To      => $self->to,
            Subject => $self->subject,
        ],
        parts => [
            $self->default_body,
            $self->create_attachment_part,
        ],
    );
}

sub send {
    args(
        my $self,
        my $mailer => {  default => 'Gmail' },
        my $pass,
    );

    eval "require Email::Send::$mailer";
    croak $@ if $@;

    my $email = $self->create_email;

    my $sender = Email::Send->new({
        mailer      => $mailer,
        mailer_args => [
            username => $self->from,
            password => $pass,
        ]
    });

    $sender->send($email);
}


1;
__END__

=encoding utf-8

=head1 NAME

Amazon::SendToKindle::LegacyPerl - It's new $module

=head1 SYNOPSIS

    use Amazon::SendToKindle::LegacyPerl;

=head1 DESCRIPTION

Amazon::SendToKindle::LegacyPerl is ...

=head1 LICENSE

Copyright (C) tokubass.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

tokubass E<lt>tokubass@cpan.orgE<gt>

=cut

