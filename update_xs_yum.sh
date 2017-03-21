#!/bin/bash

# Intended to be run from the root of your repo directory
# Requirements:
#    1. a directory named 'daily'
#    2. createrepo installed
#    3. libcdio installed
#
# This script will download XenServer snapshot ISOs, and extract them
# If the script is run more than once per day, any existing daily 
# will be overwritten.


#set -e
set -x

cd daily

# Daily snapshots are uploaded from internal builds
# the trouble is those dates might not be "today" where we are
# and might lag by days in some cases.
# To overcome this, we use the listing.html file which
# contains the directories which are present.

wget http://downloadns.citrix.com.edgesuite.net/8170/listing.html -O ./listing.html

#### Warning: if the listing format every changes - this is where things break ####
# we want to get rid of the oldest folder to make space for current - keeping last 7 should be good
oldest=`cat listing.html | sed -n '9p' | awk '{print substr($0,4,10)}'`

if [ -d "${oldest}" ]; then
  rm -rf ${oldest}
fi

#### Warning: if the listing format every changes - this is where things break ####
today=`cat listing.html | sed -n '2p' | awk '{print substr($0,4,10)}'`

#today=2016-01-19

if [ -d "${today}" ]; then
  # your choice what to do - we've decided to refesh (you could just exit and save bandwidth)
  rm -rf ${today}
fi

mkdir ${today}

cd ${today}
wget http://downloadns.citrix.com.edgesuite.net/8170/${today}/binpkg.iso
for i in `iso-info -f binpkg.iso | grep domain0/RPMS | grep rpm | awk '{print $2}'`; do mkdir -p .`dirname $i`; iso-read -i binpkg.iso -e $i -o ./$i; done
rm binpkg.iso

wget http://downloadns.citrix.com.edgesuite.net/8170/${today}/source.iso
mkdir -p domain0/SRPMS
for i in `iso-info -f source.iso | grep src.rpm | grep -v guest | awk '{print $2}'`; do mkdir -p .`dirname $i`; iso-read -i source.iso -e $i -o domain0/SRPMS/$i; done
rm source.iso
cd domain0
createrepo .
cd ..
echo "Repository created"
cd ..

curdir=`pwd`
if [ -L "./current" ]; then
  ln -sfn ${curdir}/${today} ./current
else
  ln -s ${curdir}/${today} ./current 
fi

cd ..