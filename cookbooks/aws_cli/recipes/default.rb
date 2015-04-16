package 'python'
package 'python-pip'
bash 'install AWS CLI tools' do
  code <<-EOH
  pip install awscli
  EOH
  not_if { ::File.exist?('/usr/bin/aws') }
end
