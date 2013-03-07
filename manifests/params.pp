# Class: sudo::params
#
class sudo::params {
  $source_base = "puppet:///modules/${module_name}/"
  $syntax_check = true # should be verified for all platforms

  case $::osfamily {
    debian: {
      case $::operatingsystemrelease {
        '7.0': {
          $source = ''
          $template = 'sudo/sudoers.wheezy.erb'
        }
        default: {
          $source = ''
          $template = 'sudo/sudoers.deb.erb'
        }
      }
      $package = 'sudo'
      $config_file = '/etc/sudoers'
      $config_dir = '/etc/sudoers.d/'
      $config_file_group = 'root'
    }
    redhat: {
      $package = 'sudo'
      $config_file = '/etc/sudoers'
      $config_dir = '/etc/sudoers.d/'
      $source = ''
      $template = 'sudo/sudoers.rhel.erb'
      $config_file_group = 'root'
    }
    suse: {
      $package = 'sudo'
      $config_file = '/etc/sudoers'
      $config_dir = '/etc/sudoers.d/'
      $source = ''
      $template = 'sudo/sudoers.suse.erb'
      $config_file_group = 'root'
    }
    solaris: {
      $package = 'SFWsudo'
      $config_file = '/opt/sfw/etc/sudoers'
      $config_dir = '/opt/sfw/etc/sudoers.d/'
      $source = ''
      $template = 'sudo/sudoers.solaris.erb'
      $config_file_group = 'root'
    }
    freebsd: {
      $package = 'security/sudo'
      $config_file = '/usr/local/etc/sudoers'
      $config_dir = '/usr/local/etc/sudoers.d/'
      $source = ''
      $template = 'sudo/sudoers.freebsd.erb'
      $config_file_group = 'wheel'
    }
    default: {
      case $::operatingsystem {
        gentoo: {
          $package = 'sudo'
          $config_file = '/etc/sudoers'
          $config_dir = '/etc/sudoers.d/'
          $source = ''
          $template = 'sudo/sudoers.deb.erb'
          $config_file_group = 'root'
        }
        archlinux: {
          $package = 'sudo'
          $config_file = '/etc/sudoers'
          $config_dir = '/etc/sudoers.d/'
          $source = ''
          $template = 'sudo/sudoers.archlinux.erb'
          $config_file_group = 'root'
        }
        default: {
          fail("Unsupported platform: ${::osfamily}/${::operatingsystem}")
        }
      }
    }
  }
}
