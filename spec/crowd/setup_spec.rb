require_relative '../spec_helper'

describe 'crowd::setup' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['atlassian-test']['crowd']['port'] = '1234'
      node.set['atlassian-test']['gmail']['username'] = 'shdjahsdvkasfvhja'
      node.set['atlassian-test']['database']['address'] = 'gvgavfhgad'
      node.set['atlassian-test']['database']['port'] = '4356'
      node.set['atlassian-test']['s3']['backup_bucket_name'] = 'hjfbhjebvhb'
      node.set['atlassian-test']['s3']['access_key_id'] = 'jhbdfjhbajfakd'
      node.set['atlassian-test']['s3']['secret_access_key'] = 'hvfjhadfkjvd'
    end.converge(described_recipe)
  end

  it 'should converge' do
    expect(chef_run)
  end
end
