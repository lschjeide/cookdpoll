#
# Cookbook Name:: cookdpoll
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'ruby_install'
include_recipe 'nodejs'

ruby_version = node['ruby_install']['ruby_version']
ruby_base_path = node['ruby_install']['default_ruby_base_path']
ruby_install_ruby "ruby #{ruby_version}"

ruby_path = "#{ruby_base_path}/ruby-#{ruby_version}/bin/ruby"
gem_path = "#{ruby_base_path}/ruby-#{ruby_version}/bin/gem"
rake_path = "#{ruby_base_path}/ruby-#{ruby_version}/bin/rake"
irb_path = "#{ruby_base_path}/ruby-#{ruby_version}/bin/irb"
bundle_path = "#{ruby_base_path}/ruby-#{ruby_version}/bin/bundle"
bundler_path = "#{ruby_base_path}/ruby-#{ruby_version}/bin/bunlder"

link "usr/bin/ruby" do 
	to ruby_path
end

link "usr/bin/gem" do 
	to gem_path
end

link "usr/bin/rake" do 
	to rake_path
end

link "usr/bin/irb" do 
	to irb_path
end

execute "gem install bundle bundler"

link "usr/bin/bundle" do 
	to bundle_path
end
link "usr/bin/bundler" do 
	to bundler_path
end

template '/etc/init.d/unicorn' do
  source 'unicorn.erb'
  mode 0755
end

bash "add_unicorn_service" do
  code <<-EOH
    chkconfig unicorn on
  EOH
end

execute "yum install -y libxml2 libxml2-devel libxslt libxslt-devel mysql-devel"

directory "/home/ec2-user/.bundle" do
  owner 'ec2-user'
  group 'ec2-user'
  mode '0755'
  action :create
end

file '/home/ec2-user/.bundle/config' do
	mode 0644
	content "---
BUNDLE_BUILD__NOKOGIRI: --use-system-libraries"
	owner 'ec2-user'
	group 'ec2-user'
end

execute "bundle config build.nokogiri --use-system-libraries"

file '/home/ec2-user/unicorn' do 
	mode 0644
	owner 'ec2-user'
	group 'ec2-user'
	action :touch
end
