#!/bin/sh

echo progress-bar > ~/.curlrc
gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
yum -y install epel-release pygpgme curl

if [ ! -f /usr/local/rvm/scripts/rvm ]; then
   curl -SL https://get.rvm.io | bash -s stable --with-gems="json,rails,bundler"
fi 

source /usr/local/rvm/scripts/rvm
source /etc/profile

VERSION=2.2.1 
/usr/local/rvm/bin/rvm install $VERSION
/usr/local/rvm/bin/rvm alias create default $VERSION
/usr/local/rvm/bin/rvm use $VERSION --default 
sudo -u centos -i /usr/local/rvm/bin/rvm use --default $VERSION

/usr/local/rvm/rubies/ruby-2.2.1/bin/gem install rails
/usr/local/rvm/rubies/ruby-2.2.1/bin/gem install bundler

# once ruby 2.2.1 has been set as default, install passenger
curl --fail -sSLo /etc/yum.repos.d/passenger.repo https://oss-binaries.phusionpassenger.com/yum/definitions/el-passenger.repo
yum -y install nginx passenger
yum -y install passenger-devel-5.0.21

cd /tmp/
semodule -i nginx.pp

cat << EOF > /etc/nginx/conf.d/passenger.conf
passenger_root /usr/share/ruby/vendor_ruby/phusion_passenger/locations.ini;
passenger_ruby /usr/local/rvm/gems/ruby-2.2.1/wrappers/ruby;
passenger_instance_registry_dir /var/run/passenger-instreg;
EOF
