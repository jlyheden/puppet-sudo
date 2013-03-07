require 'spec_helper'

describe 'sudo' do

  context 'debian with default params' do
    let (:facts) { {
      :osfamily  => 'debian'
    } } 
    it do should contain_package('sudo').with(
      'ensure'  => 'present'
    ) end
    it do should contain_file('/etc/sudoers').with(
      'ensure'  => 'present',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0440',
      'replace' => true,
      'require' => 'Package[sudo]'
    ).with_content(/\n\#includedir \/etc\/sudoers.d\/\n/) end
    it do should contain_file('/etc/sudoers.d/').with(
      'ensure'  => 'directory',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0550',
      'purge'   => true,
      'recurse' => true,
      'require' => 'Package[sudo]'
    ) end
  end

  context 'debian with source => puppet:///modules/sudo/sudoers.deb' do
    let (:facts) { {
      :osfamily  => 'debian'
    } }
    let (:params) { {
      :source => 'puppet:///modules/sudo/sudoers.deb'
    } }
    it do should contain_file('/etc/sudoers').with(
      'source' => 'puppet:///modules/sudo/sudoers.deb'
    ).without(['content']) end
  end

  context 'debian with content => test' do
    let (:facts) { {
      :osfamily  => 'debian'
    } }
    let (:params) { {
      :content => 'test'
    } }
    it do should contain_file('/etc/sudoers').without(['source']).with_content(/test/) end
  end

  context 'debian with source => puppet:///modules/sudo/sudoers.deb, content => test' do
    let (:facts) { {
      :osfamily  => 'debian'
    } }
    let (:params) { {
      :source   => 'puppet:///modules/sudo/sudoers.deb',
      :content  => 'test'
    } }
    it do
      expect {
        should contain_class('sudo::params')
      }.to raise_error(Puppet::Error, /Only one of parameters source and content can be set/)
    end
  end

  context 'ubuntu with autoupgrade => true' do
    let (:facts) { {
      :operatingsystem  => 'Ubuntu'
    } }
    let (:params) { {
      :autoupgrade  => true
    } }
    it do should contain_package('sudo').with(
      'ensure'  => 'latest'
    ) end
  end

  context 'debian with config_dir => /custom/dir' do
    let (:facts) { {
      :osfamily  => 'debian',
    } }
    let (:name) { 'admins' }
    let (:title) { 'admins' }
    let (:params) { {
      :config_dir  => '/custom/dir'
    } }
    it do
      expect {
        should contain_class('sudo')
      }.to raise_error(Puppet::Error, /Parameter config_dir must end with slash/) 
    end
  end

  context 'with invalid operatingsystem' do
    let (:facts) { {
      :operatingsystem => 'beos'
    } }
    it do
      expect {
        should contain_class('sudo::params')
      }.to raise_error(Puppet::Error, /Unsupported platform:/)
    end
  end

end
