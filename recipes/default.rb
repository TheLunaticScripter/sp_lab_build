#
# Cookbook:: sp_lab_build
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

case node['hostname']
when /ad/
  win_ad_server 'the_wall.local' do
    safe_mode_pass '!QAZXSW@1qzxsw2'
    type 'forest'
  end
  win_ad_ou 'Testing' do
    path 'DC=the_wall,DC=local'
  end
  win_ad_svcacct 'sqlsvc' do
    path 'OU=Testing,DC=the_wall,DC=local'
    pswd '!QAZXSW@1qazxsw2'
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
      pswd '!QAZXSW@1qazxsw2'
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
when /sql-n1/
  win_ad_client "Join #{node['hostname']} to domain" do
    domain_name 'the_wall.local'
    domain_user 'jsnow'
    domain_pswd '!QAZXSW@1qazxsw2'
    path 'OU=Testing,DC=the_wall,DC=local'
  end
  include_recipe 'powershell::powershell5'
  ls_sql_server_install 'Install SQL Server 2012' do
    netfx3_source 'C:\\Sources\\sxs'
    sys_admin_group 'the_wall.local\\Sql_Admins'
    sql_svc_account 'the_wall.local\\sqlsvc'
    sql_svc_acct_pswd '!QAZXSW@1qazxsw2'
    install_source 'C:\\Sources\\SQL_2012\\setup.exe'
  end
  win_cluster_server 'SQLClstr' do
    ip_address '172.31.9.27'
  end
when /sql-n2/
  win_ad_client "Join #{node['hostname']} to domain" do
    domain_name 'the_wall.local'
    domain_user 'jsnow'
    domain_pswd '!QAZXSW@1qazxsw2'
    path 'OU=Testing,DC=the_wall,DC=local'
  end
  include_recipe 'powershell::powershell5'
  ls_sql_server_install 'Install SQL Server 2012' do
    netfx3_source 'C:\\Sources\\sxs'
    sys_admin_group 'the_wall.local\\Sql_Admins'
    sql_svc_account 'the_wall.local\\sqlsvc'
    sql_svc_acct_pswd '!QAZXSW@1qazxsw2'
    install_source 'C:\\Sources\\SQL_2012\\setup.exe'
  end
  win_cluster_server 'SQLClst' do
    action :join
    creator false
  end
end
