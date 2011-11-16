#!/bin/bash

# Script on the amd64-host to compile amd64-images and update them on mptcp.info.ucl.ac.be

trap "mutt -s \"$0 crontab-failure\" -- christoph.paasch@uclouvain.be < /tmp/$0.log; exit 1" ERR

cd $HOME

if [ -e *.deb ] ;
then
	rm *.deb
fi

cd $HOME/mptcp

git checkout mptcp_trunk_3.0.x
git pull

DATE=`date +%Y%m%d`
export CONCURRENCY_LEVEL=3
fakeroot make-kpkg --initrd -j 2 --revision $DATE kernel-image kernel-headers
kernel_version=`ls debian/linux-image-*/lib/modules/`

cd $HOME
scp -C *.deb root@mptcp.info.ucl.ac.be:/tmp/

scp -C bin/setup_amd64.sh root@mptcp.info.ucl.ac.be:/tmp/

ssh root@mptcp.info.ucl.ac.be "/tmp/setup_amd64.sh $kernel_version $DATE"

ssh root@mptcp.info.ucl.ac.be "rm /tmp/setup_amd64.sh"

rm *.deb
