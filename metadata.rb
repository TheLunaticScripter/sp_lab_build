name 'sp_lab_build'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'All Rights Reserved'
description 'Installs/Configures sp_lab_build'
long_description 'Installs/Configures sp_lab_build'
version '0.8.1'
chef_version '>= 12.1' if respond_to?(:chef_version)

depends 'win_ad'
depends 'powershell'
depends 'ls_sql_server'
depends 'win_cluster'

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/sp_lab_build/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/sp_lab_build'
