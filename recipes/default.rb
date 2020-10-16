#
# Cookbook:: temPi_setup
# Recipe:: default
#
# Copyright:: 2020, Chef Software, Inc., All Rights Reserved.

# Set timezone
timezone 'America/New_York'

# Install packages
package 'git'
package 'ntp'
package 'python3-pip'
package 'python3-numpy'

# Setup InfluxDB repository
apt_repository 'influxdata' do
  uri        'https://repos.influxdata.com/debian'
  distribution 'buster'
  components ['stable']
  key 'https://repos.influxdata.com/influxdb.key'
end

# Install telegraf
package 'telegraf'

# Create flags directory
directory '/opt/apps/flags' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

# Create application directories
directory '/opt/apps/temPi/bin' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

directory '/opt/apps/temPi/data' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

# Install python modules
unless File.exist?('/opt/apps/flags/python_modules_installed')

  # Install modules with pip3
  execute 'pip3_install_adafruit' do
    command 'pip3 install Adafruit_DHT'
    action :run
  end

  # Set flag
  file '/opt/apps/flags/python_modules_installed' do
    content 'Python modules are installed.'
    owner 'root'
    group 'root'
    mode '0644'
    action :create
  end
end

# Drop the temPi script
template '/opt/apps/temPi/bin/temPi.py' do
  source 'temPi.py.erb'
  owner 'root'
  group 'root'
  mode '0744'
  action :create
end

# Create cronjob for temPi
cron 'temPi' do
  hour '*'
  minute '*'
  command 'python3 /opt/apps/temPi/bin/temPi.py > /dev/null 2>&1'
  action :create
end
