# Define: sudo::conf
#
# This module manages sudoa configurations
#
# Parameters:
#   [*ensure*]
#     Ensure if present or absent.
#     Default: present
#
#   [*priority*]
#     Prefix file name with $priority
#     Default: 10
#
#   [*content*]
#     Content of configuration snippet.
#     Default: undef
#
#   [*source*]
#     Source of configuration snippet.
#     Default: undef
#
#   [*sudo_config_dir*]
#     Where to place configuration snippets.
#     Only set this, if your platform is not supported or
#     you know, what you're doing.
#     Default: auto-set, platform specific
#
#   [*syntax_check*]
#     If entry should be syntax checked before added.
#     Uses visudo -c and removes the file in case
#     syntax check fails. In case of failures you
#     will see this resource being reapplied on
#     every puppet run
#     Default: platform specific
#
# Actions:
#   Installs sudo configuration snippets
#
# Requires:
#   Class sudo
#
# Sample Usage:
#   sudo::conf { 'admins':
#     source => 'puppet:///files/etc/sudoers.d/admins',
#   }
#
# [Remember: No empty lines between comments and class definition]
define sudo::conf (
  $ensure           = present,
  $priority         = 10,
  $content          = 'UNDEF',
  $source           = 'UNDEF',
  $sudo_config_dir  = 'UNDEF',
  $syntax_check     = 'UNDEF'
) {

  include sudo

  $source_real = $source ? {
    'UNDEF' => undef,
    ''      => undef,
    default => $source
  }
  $content_real = $content ? {
    'UNDEF' => undef,
    ''      => undef,
    default => "${content}\n"
  }
  $sudo_config_dir_real = $sudo_config_dir ? {
    'UNDEF' => $sudo::config_dir_real,
    default => $sudo_config_dir
  }
  $syntax_check_real = $syntax_check ? {
    'UNDEF' => $sudo::params::syntax_check,
    default => $syntax_check
  }

  $dname = "${priority}_${name}"

  if $content_real == undef and $source_real == undef {
    fail('One of parameters content and source must be set')
  }
  if $content_real != undef and $source_real != undef {
    fail('Only one of parameters content and source can be set')
  }
  if $sudo_config_dir_real !~ /\/$/ {
    fail('Parameter sudo_config_dir must end with slash')
  }

  case $syntax_check_real {
    true: {
      exec { "sudo-syntax-check-${dname}":
        command     => "visudo -c -f ${sudo_config_dir_real}${dname} || (rm -f ${sudo_config_dir_real}${dname} && exit 1)",
        refreshonly => true,
        path        => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin' ]
      }
      File[$dname] { notify => Exec["sudo-syntax-check-${dname}"] }
    }
    false: {}
    default: {
      fail("Unsupported value ${syntax_check_real} for parameter syntax_check")
    }
  }

  file { $dname:
    ensure  => $ensure,
    path    => "${sudo_config_dir_real}${priority}_${name}",
    owner   => 'root',
    group   => $sudo::params::config_file_group,
    mode    => '0440',
    source  => $source_real,
    content => $content_real,
  }
}
