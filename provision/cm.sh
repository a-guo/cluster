#!/bin/bash

echo "Installing Splunk! ... please wait "
sudo su -
apt-get update > /dev/null 2>&1
apt-get install -y wget > /dev/null 2>&1

# add splunk user
useradd -m -c "splunk user" splunk  -s /bin/bash

echo "Downloading Splunk"

wget -O splunk-7.2.3-06d57c595b80-Linux-x86_64.tgz 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=7.2.3&product=splunk&filename=splunk-7.2.3-06d57c595b80-Linux-x86_64.tgz&wget=true' > /dev/null 2>&1

echo "moving splunk to /opt"

mv splunk-7.2.3-06d57c595b80-Linux-x86_64.tgz /opt > /dev/null 2>&1

cd /opt

echo "untar the splunk"

tar -xzvf splunk-7.2.3-06d57c595b80-Linux-x86_64.tgz > /dev/null 2>&1 && chown -R splunk.splunk splunk > /dev/null 2>&1

echo "su splunk"

su - splunk

cd splunk/bin

cat > /opt/splunk/etc/system/local/user-seed.conf << EOF
[user_info]
USERNAME = admin
PASSWORD = changeme
EOF

echo "ssl"

# cd $SPLUNK_HOME/etc/auth
# mkdir mycerts
cd $SPLUNK_HOME/etc/auth/mycerts
openssl req -x509 -newkey rsa:4096 -keyout mySplunkWebPrivateKey.key -out mySplunkWebCertificate.pem -days 365 -nodes -subj '/CN=localhost'

echo $(ls $SPLUNK_HOME/etc/system/local/)
echo $(pwd)
cd $SPLUNK_HOME/etc/system/local
echo $(pwd)
cd $SPLUNK_HOME/etc/system/local
echo $(pwd)
touch web.conf
cat > $SPLUNK_HOME/etc/system/local/web.conf << EOF
[settings]
enableSplunkWebSSL = true
privKeyPath = $SPLUNK_HOME/etc/auth/mycerts/mySplunkWebPrivateKey.key
# Absolute paths may be used. non-absolute paths are relative to $SPLUNK_HOME

serverCert = $SPLUNK_HOME/etc/auth/mycerts/mySplunkWebCertificate.pem
# Absolute paths may be used. non-absolute paths are relative to $SPLUNK_HOME
EOF

# cat > $SPLUNK_HOME/etc/system/local/server.conf << EOF
# [clustering]
# mode = master
# replication_factor = 3
# search_factor = 2
# pass4SymmKey = whatever
# cluster_label = cluster1
# EOF

# echo "Starting Splunk"
# ./splunk start --accept-license --answer-yes
#
# echo "Splunk is available on http://localhost:8021"
