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