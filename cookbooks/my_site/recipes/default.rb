#
# Cookbook Name:: my_site
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
powershell_script 'Install IIS' do
  code 'Add-WindowsFeature Web-Server'
  guard_interpreter :powershell_script
  not_if "(Get-WindowsFeature -Name Web-Server).Installed"
end

file 'c:\temp.txt'

iis_site 'Default Web Site' do
    action [:stop, :delete]
end

remote_directory "#{node['iis']['docroot']}/mysite" do
  source "mysite"
  action [:delete,:create]
end

iis_site 'mysite' do
  protocol :http
  port 80
  path "#{node['iis']['docroot']}/mysite"
  action [:add, :start]
end
