#!/bin/bash

find /home/*/public_html -maxdepth 1 -type d \( -name "gemfind" -o -name "sync_gemfind" \) | cut -d / -f3  > accounts

	for i in `cat accounts`
	do 
		cd /home/$i/public_html
                website=`grep  $i$ /etc/trueuserdomains | cut -d : -f1`
	        	if [ -f "app/etc/local.xml" ]; then
				echo "$website >>> MAGENTO"
				echo "Common files:"
				echo "============="
				cd gemfind
				ls pending/ | sort > file1
				ls imported/ | sort > file2
				comm -12 file1 file2 > common
			        cat common >> /home/test/csvremoved.$(date +%Y-%m-%d).log	
			else
                        	echo "$website >>> WORDPRESS"
				echo "Common files:"
                                echo "============="
				cd sync_gemfind
				ls pending/ | sort > file1
				ls completed/ | sort > file2
				comm -12 file1 file2 > common
				cat common >> /home/test/csvremoved.$(date +%Y-%m-%d).log
		       
                        fi		
        done
