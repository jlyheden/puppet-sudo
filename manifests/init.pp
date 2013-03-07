# Class: sudo
#
# This module manages sudo
#
# Parameters:
#   [*ensure*]
#     Ensure if present or absent.
#     Default: present
#
#   [*autoupgrade*]
#     Upgrade package automatically, if there is a newer version.
#     Default: false
#
#   [*package*]
#     Name of the package.
#     Only set this, if your platform is not supported or you know,
#     what you're doing.
#     Default: auto-set, platform specific
#
#   [*purge*]
#     Whether or not to purge sudoers.d directory
#     Default: true
#
#   [*config_file*]
#     Main configuration file.
#     Only set this, if your platform is not supported or you know,
#     what you're doing.
#     Default: auto-set, platform specific
#
#   [*config_file_replace*]
#     Replace configuration file with that one delivered with this module
#     Default: true
#
#   [*config_dir*]
#     Main configuration directory
#     Only set this, if your platform is not supported or you know,
#     what you're doing.
#     Default: auto-set, platform specific
#
#   [*source*]
#     Alternate source file location
#     Only set this, if your platform is not supported or you know,
#     what you're doing.
#     Default: auto-set, platform specific
#
#   [*content*]
#     Alternate sudoers file content
#     String value to pass to sudoers, could be from a template
#     evaluated in another scope
#     Default: auto-set, platform specific
#
# Actions:
#   Installs locales package and generates specified locales
#
# Requires:
#   Nothing
#
# Sample Usage:
#   class { 'sudo': }
#
# [Remember: No empty lines between comments and class definition]
class sudo (
  $ensure               = 'present',
  $autoupgrade          = false,
  $package              = 'UNDEF',
  $purge                = true,
  $config_file          = 'UNDEF',
  $config_file_replace  = true,
  $config_dir           = 'UNDEF',
  $source               = 'UNDEF',
  $content              = 'UNDEF'
) {

  include sudo::params

  $package_real = $package ? {
    'UNDEF' => $sudo::params::package,
    default => $package
  }
  $config_file_real = $config_file ? {
    'UNDEF' => $sudo::params::config_file,
    default => $config_file
  }
  $config_dir_real = $config_dir ? {
    'UNDEF' => $sudo::params::config_dir,
    default => $config_dir
  }
  $source_real = $source ? {
    'UNDEF'   => $sudo::params::source ? {
      ''      => '',
      default => $sudo::params::source
    },
    default   => $source
  }
  $content_real = $content ? {
    'UNDEF'   => $sudo::params::template ? {
      ''      => undef,
      default => template($sudo::params::template)
    },
    default   => $content
  }

  if $config_dir_real !~ /\/$/ {
    fail('Parameter config_dir must end with slash')
  }

  # 1. If content is set and regardless of source is set, use content
  # 2. If content is not set and source is set, use source
  # 3. If no content or source is set: use template
  case $content {
    undef, '', 'UNDEF': {
      case $source {
        undef, '', 'UNDEF': { File[$config_file_real] { content => $content_real } }
        default: { File[$config_file_real] { source => $source_real } }
      }
    }
    default: { File[$config_file_real] { content => $content_real } }
  }

  if $source != 'UNDEF' and $content != 'UNDEF' {
    fail('Only one of parameters source and content can be set')
  }

  case $ensure {
    /(present)/: {
      $dir_ensure = 'directory'
      if $autoupgrade == true {
        $package_ensure = 'latest'
      } else {
        $package_ensure = 'present'
      }
    }
    /(absent)/: {
      $package_ensure = 'absent'
      $dir_ensure = 'absent'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  package { $package_real:
    ensure => $package_ensure,
  }

  file { $config_file_real:
    ensure  => $ensure,
    owner   => 'root',
    group   => $sudo::params::config_file_group,
    mode    => '0440',
    replace => $config_file_replace,
    require => Package[$package_real],
  }

  file { $config_dir_real:
    ensure  => $dir_ensure,
    owner   => 'root',
    group   => $sudo::params::config_file_group,
    mode    => '0550',
    recurse => $purge,
    purge   => $purge,
    require => Package[$package_real],
  }
}
