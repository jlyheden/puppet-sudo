require 'spec_helper'

describe 'sudo::conf' do

  context 'debian with default params' do
    let (:facts) { {
      :osfamily  => 'debian',
    } } 
    let (:name) { 'admins' }
    let (:title) { 'admins' }
    #let (:params) { {
    #  :object       => 'Domain Users',
    #  :object_type  => 'group',
    #  :permission   => 'allow'
    #} } 
    it do
      expect {
        should contain_class('sudo')
      }.to raise_error(Puppet::Error, /One of parameters content and source must be set/)
    end
  end

  context 'debian with source => text, content => text' do
    let (:facts) { {
      :osfamily  => 'debian',
    } }
    let (:name) { 'admins' }
    let (:title) { 'admins' }
    let (:params) { {
      :source   => 'text',
      :content  => 'text'
    } } 
    it do
      expect {
        should contain_class('sudo')
      }.to raise_error(Puppet::Error, /Only one of parameters content and source can be set/)
    end
  end

  context 'debian with source => text' do
    let (:facts) { {
      :osfamily  => 'debian',
    } }
    let (:name) { 'admins' }
    let (:title) { 'admins' }
    let (:params) { {
      :source   => 'text'
    } } 
    it do should contain_file('10_admins').with(
      'ensure'  => 'present',
      'path'    => '/etc/sudoers.d/10_admins',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0440',
      'source'  => 'text',
      'notify'  => 'Exec[sudo-syntax-check-10_admins]'
    ).without(['content']) end
    it do should contain_exec('sudo-syntax-check-10_admins').with(
      'command' => 'visudo -c -f /etc/sudoers.d/10_admins || (rm -f /etc/sudoers.d/10_admins && exit 1)'
    ) end
  end

  context 'debian with content => text' do
    let (:facts) { {
      :osfamily  => 'debian',
    } }
    let (:name) { 'admins' }
    let (:title) { 'admins' }
    let (:params) { {
      :content   => 'text'
    } }
    it do should contain_file('10_admins').with(
      'ensure'  => 'present',
      'path'    => '/etc/sudoers.d/10_admins',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0440',
      'notify'  => 'Exec[sudo-syntax-check-10_admins]'
    ).without(['source']).with_content(/text/) end
  end

  context 'debian with content => text, syntax_check => false' do
    let (:facts) { {
      :osfamily  => 'debian',
    } }
    let (:name) { 'admins' }
    let (:title) { 'admins' }
    let (:params) { {
      :content      => 'text',
      :syntax_check => false
    } }
    it do should contain_file('10_admins').with(
      'ensure'  => 'present',
      'path'    => '/etc/sudoers.d/10_admins',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0440'
    ).without(['source','notify']).with_content(/text/) end
    it do should_not contain_exec('sudo-syntax-check-10_admins') end
  end

  context 'debian with content => text, sudo_config_dir => /custom/dir/' do
    let (:facts) { {
      :osfamily  => 'debian',
    } }
    let (:name) { 'admins' }
    let (:title) { 'admins' }
    let (:params) { {
      :content          => 'text',
      :sudo_config_dir  => '/custom/dir/'
    } }
    it do should contain_file('10_admins').with(
      'ensure'  => 'present',
      'path'    => '/custom/dir/10_admins',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0440',
      'notify'  => 'Exec[sudo-syntax-check-10_admins]'
    ).without(['source']) end
    it do should contain_exec('sudo-syntax-check-10_admins').with(
      'command' => 'visudo -c -f /custom/dir/10_admins || (rm -f /custom/dir/10_admins && exit 1)'
    ) end
  end

  context 'debian with content => text, config_dir => /custom/dir/ set in sudo class' do
    let (:facts) { {
      :osfamily  => 'debian',
    } }
    let (:name) { 'admins' }
    let (:title) { 'admins' }
    let (:params) { {
      :content          => 'text'
    } }
    let (:pre_condition) do [
      'class { "sudo": config_dir => "/custom/dir/" }',
    ]
    end
    it do should contain_file('10_admins').with(
      'ensure'  => 'present',
      'path'    => '/custom/dir/10_admins',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0440',
      'notify'  => 'Exec[sudo-syntax-check-10_admins]'
    ).without(['source']) end
    it do should contain_exec('sudo-syntax-check-10_admins').with(
      'command' => 'visudo -c -f /custom/dir/10_admins || (rm -f /custom/dir/10_admins && exit 1)'
    ) end
  end

  context 'debian with content => text, sudo_config_dir => /custom/dir' do
    let (:facts) { {
      :osfamily  => 'debian',
    } }
    let (:name) { 'admins' }
    let (:title) { 'admins' }
    let (:params) { {
      :content          => 'text',
      :sudo_config_dir  => '/custom/dir'
    } }
    it do
      expect {
        should contain_class('sudo')
      }.to raise_error(Puppet::Error, /Parameter sudo_config_dir must end with slash/)
    end
  end

end
