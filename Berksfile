source "https://supermarket.chef.io"

Dir['./cookbooks/*'].each do |path|
  cookbook(File.basename(path), path: path)
end
