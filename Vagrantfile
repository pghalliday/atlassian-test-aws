Vagrant.configure(2) do |config|
  config.vm.box = 'chef/centos-7.0'
  config.vm.provider 'virtualbox' do |vb|
    vb.memory = '1024'
  end

  config.vm.define 'jira' do |jira|
    jira.vm.network 'private_network', ip: '192.168.33.10'
    jira.vm.provision 'chef_solo' do |chef|
      chef.add_recipe 'jira'
    end
  end

  config.vm.define 'stash' do |stash|
    stash.vm.network 'private_network', ip: '192.168.33.11'
    stash.vm.provision 'chef_solo' do |chef|
      chef.add_recipe 'stash'
    end
  end

  config.vm.define 'bamboo' do |bamboo|
    bamboo.vm.network 'private_network', ip: '192.168.33.12'
    bamboo.vm.provision 'chef_solo' do |chef|
      chef.add_recipe 'bamboo'
    end
  end
end
