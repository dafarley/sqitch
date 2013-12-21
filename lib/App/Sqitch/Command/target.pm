package App::Sqitch::Command::target;

use 5.010;
use strict;
use warnings;
use utf8;
use Mouse;
use Locale::TextDomain qw(App-Sqitch);
use App::Sqitch::X qw(hurl);
use URI::db;
use namespace::autoclean;

extends 'App::Sqitch::Command';

our $VERSION = '0.990';

has verbose => (
    is      => 'ro',
    isa     => 'Int',
    default => 0,
);

has registry => (
    is  => 'ro',
    isa => 'Str',
);

has client => (
    is  => 'ro',
    isa => 'Str',
);

sub options {
    return qw(
        registry|r=s
        client|c=s
        v|verbose+
    );
}

sub configure {
    my ( $class, $config, $options ) = @_;

    # No config; target config is actually targets.
    return $options;
}

sub execute {
    my ( $self, $action ) = (shift, shift);
    $action ||= 'list';
    $action =~ s/-/_/g;
    my $meth = $self->can($action) or hurl target => __x(
        'Unknown action "{action}"',
        action => $action,
    );
    return $self->$meth(@_);
}

sub list {
    my $self    = shift;
    my $sqitch  = $self->sqitch;
    my %targets = $sqitch->config->get_regexp(key => qr/^target[.][^.]+[.]uri$/);

    my $format = $self->verbose ? "%s\t%s" : '%s';
    for my $key (sort keys %targets) {
        my ($target) = $key =~ /target[.]([^.]+)/;
        $sqitch->emit(sprintf $format, $target, $targets{$key});
    }

    return $self;
}


sub _name_uri {
    my ($self, $name, $uri) = @_;
}

sub add {
    my ($self, $name, $uri) = @_;
    $self->usage unless $name && $uri;
    $uri = URI::db->new($uri, 'db:');

    return $self;
}

sub set_uri {
    my ($self, $name, $uri) = @_;
}

sub set_registry {
    my ($self, $name, $registry) = @_;
}

sub set_client {
    my ($self, $name, $client) = @_;
}

sub remove {
    my ($self, $name) = @_;
}

sub rm { shift->remove(@_) }

sub rename {
    my ($self, $old, $new) = @_;
}

sub show {
    my ($self, $name) = @_;
}

1;

__END__

=head1 Name

App::Sqitch::Command::target - Add, modify, or list Sqitch target databases

=head1 Synopsis

  my $cmd = App::Sqitch::Command::target->new(%params);
  $cmd->execute;

=head1 Description

Manages Sqitch targets, which are stored in the local configuration file.

=head1 Interface

=head2 Instance Methods

=head3 C<execute>

  $target->execute($command);

Executes the C<target> command.

=head1 See Also

=over

=item L<sqitch-target>

Documentation for the C<target> command to the Sqitch command-line client.

=item L<sqitch>

The Sqitch command-line client.

=back

=head1 Author

David E. Wheeler <david@justatheory.com>

=head1 License

Copyright (c) 2012-2013 iovation Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

=cut
