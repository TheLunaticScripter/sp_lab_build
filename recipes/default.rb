#
# Cookbook:: sp_lab_build
# Recipe:: default
#
# Copyright:: 2017, John Snow, All Rights Reserved.

require 'chef-vault'

password = ChefVault::Item.load('credentials', 'lab')
sql_pswd = ChefVault::Item.load('sql_creds', 'sql')

case node['hostname']
when /ad/
  win_ad_server 'the_wall.local' do
    safe_mode_pass password['password']
    type 'forest'
  end
  win_ad_ou 'Testing' do
    path 'DC=the_wall,DC=local'
  end
  win_ad_svcacct 'sqlsvc' do
    path 'OU=Testing,DC=the_wall,DC=local'
    pswd sql_pswd['password']
  end
  %w(
    jsnow
    SP_13Farm
    SP_Setup
    SP_Web_Pool_Acct
    SP_Svc_Pool_Acct
  ).each do |user_name|
    win_ad_svcacct user_name do
      path 'OU=Testing,DC=the_wall,DC=local'
      pswd password['password']
    end
  end
  win_ad_group 'Sql_Admins' do
    path 'OU=Testing,DC=the_wall,DC=local'
  end
  %w(
    jsnow
    sqlsvc
    Administrator
    SP_13Farm
    SP_Setup
  ).each do |user|
    win_ad_group_member "Add #{user} to Sql_Admins group" do
      group_name 'Sql_Admins'
      user_name user
      type 'user'
    end
  end
  %w(
    jsnow
    SP_Setup
  ).each do |user|
    win_ad_group_member 'Add jsnow to Domain Admins' do
      group_name 'Domain Admins'
      user_name user
      type 'user'
    end
  end
  win_ad_dns 'server-name' do
    zone_name 'the_wall.local'
    ipv4_address '10.0.0.2'
    create_ptr false
  end
when /sql1/
  win_ad_client "Join #{node['hostname']} to domain" do
    domain_name 'the_wall.local'
    domain_user 'jsnow'
    domain_pswd password['password']
    path 'OU=Testing,DC=the_wall,DC=local'
  end
  include_recipe 'powershell::powershell5'
  ls_sql_server_install 'Install SQL Server 2012' do
    netfx3_source 'C:\\Sources\\sxs'
    sys_admin_group 'the_wall.local\\Sql_Admins'
    sql_svc_account 'the_wall.local\\sqlsvc'
    sql_svc_acct_pswd sql_pswd['password']
    install_source 'C:\\Sources\\SQL_2012\\setup.exe'
  end
  win_cluster_server 'SQLClstr' do
    ip_address '172.31.9.27'
  end
when /sql2/
  win_ad_client "Join #{node['hostname']} to domain" do
    domain_name 'the_wall.local'
    domain_user 'jsnow'
    domain_pswd password['password']
    path 'OU=Testing,DC=the_wall,DC=local'
  end
  include_recipe 'powershell::powershell5'
  ls_sql_server_install 'Install SQL Server 2012' do
    netfx3_source 'C:\\Sources\\sxs'
    sys_admin_group 'the_wall.local\\Sql_Admins'
    sql_svc_account 'the_wall.local\\sqlsvc'
    sql_svc_acct_pswd sql_pswd['password']
    install_source 'C:\\Sources\\SQL_2012\\setup.exe'
  end
  win_cluster_server 'SQLClst' do
    action :join
    creator false
  end
end
