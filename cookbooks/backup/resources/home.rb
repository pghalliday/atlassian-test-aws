actions :enable, :backup, :restore
default_action :enable

attribute :name, name_attribute: true, kind_of: String, required: true
attribute :s3_bucket, kind_of: String, required: true
attribute :s3_access_key_id, kind_of: String, required: true
attribute :s3_secret_access_key, kind_of: String, required: true
attribute :home, kind_of: String, required: true
attribute :user, kind_of: String, required: true
