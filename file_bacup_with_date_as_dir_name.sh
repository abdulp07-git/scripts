#!/bin/bash
cd /backup/SITEBACKUP/
day=`date +'%d%m%Y'`
mkdir $day

cp -r `find . -mindepth 1 -maxdepth 1 -type d  -exec stat -c "%Y %n" {} \;  |sort -n -r |head -2 |tail -1|awk '{print $2}'`/* $day


cd $day
rm -f *.gz
#rsync -ravz -e "ssh -p 2014" gigenet@b102:/backup/sitebackup/* .
#rsync -ravz -e "ssh -p 2014" gigenet@e655:/backup/sitebackup/* .
#rsync -ravz -e "ssh -p 2014" gigenet@c121:/backup/sitebackup/* .
rsync -ravz -e "ssh -p 2014" gigenet@a131:/backup/sitebackup/* .
rsync -ravz gigenet@server.goldanddiamond.com:/backup/sitebackup/* .
