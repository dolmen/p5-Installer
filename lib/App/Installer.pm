package App::Installer;
# ABSTRACT: Application class for Installer

use Moo;
use MooX::Options protect_argv => 0;
use Path::Tiny;
use IO::All;

option 'file' => (
  is => 'ro',
  format => 's',
  short => 'f',
  lazy => 1,
  default => sub { '.installer' },
);

option 'url' => (
  is => 'ro',
  format => 's',
  short => 'u',
  predicate => 1,
);

has file_path => (
  is => 'ro',
  lazy => 1,
  default => sub { path($_[0]->file)->absolute->stringify },
);

sub BUILD {
  my ( $self ) = @_;
  my $target = shift @ARGV;
  die "Need a target to deploy to" unless $target;
  $target = path($target)->absolute->stringify;
  my $installer_code;
  if ($self->has_url) {
    $installer_code = io($self->url)->get->content;
  } else {
    $installer_code = io($self->file_path)->all;
  }
  my $target_class = 'App::Installer::Sandbox'.$$;

  my ( $err );
  {
    local $@;
    eval <<EVAL;
package $target_class;
no strict;
no warnings;
use Installer;

install_to '$target' => sub {
  $installer_code;
};

EVAL
    $err = $@;
  }

  if ($err) { die "$err" };

}

1;

=encoding utf8

=head1 DESCRIPTION

See L<installer> and for more information
