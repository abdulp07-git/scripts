#!/bin/bash

find /home/*/public_html -maxdepth 1 -type d \( -name "gemfind" -o -name "sync_gemfind" \) | cut -d / -f3  > accounts

	for i in `cat accounts`
	do 
		cd /home/$i/public_html
                website=`grep  $i$ /etc/trueuserdomains | cut -d : -f1`
	        	if [ -f "app/etc/local.xml" ]; then
				echo "$website >>> MAGENTO" >> /home/CSVREMOVER/report.txt
				echo "Common files:" >> /home/CSVREMOVER/report.txt
				echo "=============" >> /home/CSVREMOVER/report.txt
				cd gemfind
				ls pending/ | sort > file1
				ls imported/ | sort > file2
				comm -12 file1 file2 > common
			        cat common >> /home/CSVREMOVER/report.txt
					for j in `cat common`;do rm -rf ./pending/$i ./imported/$i;done;
			else
                        	echo "$website >>> WORDPRESS" >> /home/CSVREMOVER/report.txt
				echo "Common files:" >> /home/CSVREMOVER/report.txt
                                echo "=============" >> /home/CSVREMOVER/report.txt
				cd sync_gemfind
				ls pending/ | sort > file1
				ls completed/ | sort > file2
				comm -12 file1 file2 > common
				cat common >> /home/CSVREMOVER/report.txt
					for j in `cat common`;do rm -rf ./pending/$i ./completed/$i;done;
		       
                        fi		
        done

mail -s "CSV files removed DEV Server" tvcfred@gmail.com < /home/CSVREMOVER/report.txt
rm -f /home/CSVREMOVER/report.txt
