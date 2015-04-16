require_relative '../spec_helper'

describe 'reverse_proxy::setup' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['atlassian-test']['proxy_port'] = '80'
      node.set['atlassian-test']['route53']['hosted_zone_id'] = 'hbajvbfhaj'
      node.set['atlassian-test']['route53']['access_key_id'] = 'dbhavjvbj'
      node.set['atlassian-test']['route53']['secret_access_key'] = 'hdbfvhabjafnv'
      node.set['opsworks']['instance']['ip'] = '1.2.3.4'
      node.set['atlassian-test']['proxy_ssh_host'] = 'proxy-ssh.my.domain.'
      node.set['atlassian-test']['crowd']['proxy_host'] = 'crowd.my.domain.'
      node.set['atlassian-test']['jira']['proxy_host'] = 'jira.my.domain.'
      node.set['atlassian-test']['confluence']['proxy_host'] = 'confluence.my.domain.'
      node.set['atlassian-test']['stash']['proxy_host'] = 'stash.my.domain.'
      node.set['atlassian-test']['bamboo']['proxy_host'] = 'bamboo.my.domain.'
    end.converge(described_recipe)
  end

  it 'should converge' do
    expect(chef_run)
  end
end
