Vagrant.configure(2) do |config|
  config.vm.box = 'dummy'
  config.vm.box_url = 'https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box'

  config.vm.provider :aws do |aws, override|
    aws_config = JSON.parse(IO.read('./aws-config.json'))
    aws.access_key_id = aws_config.access_key_id
    aws.secret_access_key = aws_config.secret_access_key
    aws.keypair_name = aws_config.keypair_name
    override.ssh.private_key_path = aws_config.private_key_path

    aws.instance_type = 't1.micro'
    aws.ami = 'ami-7747d01e'
    override.ssh.username = 'ubuntu'
  end

  config.vm.define 'jira' do |jira|
    jira.vm.provision 'chef_solo' do |chef|
      chef.add_recipe 'jira'
    end
  end

  config.vm.define 'stash' do |stash|
    stash.vm.provision 'chef_solo' do |chef|
      chef.add_recipe 'stash'
    end
  end

  config.vm.define 'bamboo' do |bamboo|
    bamboo.vm.provision 'chef_solo' do |chef|
      chef.add_recipe 'bamboo'
    end
  end
end
