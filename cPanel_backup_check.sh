#!/bin/bash

backlogdir=/usr/local/cpanel/logs/cpbackup;


# check if new backups are enabled
function check_new_backups() {
 echo -e "\n\n\033[36m[ cPTech Backup Report v2.1 ]\033[0m";
 new_enabled=$(grep BACKUPENABLE /var/cpanel/backups/config 2>/dev/null | awk -F"'" '{print $2}')
 new_cron=$(crontab -l | grep bin\/backup | awk '{print $1,$2,$3,$4,$5}')
 if [ "$new_enabled" = "yes" ]; then new_status='\033[1;32m'Enabled'\033[0m'
 else new_status='\033[1;31m'Disabled'\033[0m'
 fi
 echo -e "New Backups = $new_status\t\t(cron time: $new_cron)\t\t/var/cpanel/backups/config"
}


# look at start, end times.  print number of users where backup was attempted
function print_start_end_times () {
echo -e "\n\033[36m[ Current Backup Logs in "$backlogdir" ]\033[0m";
if [ -e $backlogdir ]; then
 cd $backlogdir;
 for i in `\ls`; do
  echo -n $i": "; grep "Started" $i; echo -n "Ended ";
  \ls -lrth | grep $i | awk '{print $6" "$7" "$8}';
  echo -ne " Number of users backed up:\t";  grep "user :" $i | wc -l;
 done;
fi;
}

function print_num_expected_users () {
 echo -e "\n\033[36m[ Expected Number of Users ]\033[0m";
 wc -l /etc/trueuserdomains;
}

function exceptions_heading() {
 echo -e "\n\033[36m[ A count of users enabled/disabled ]\033[0m";
}


function list_new_exceptions() {
# TODO: math
newsuspended=$(egrep "=1" /var/cpanel/users/* | grep "SUSPENDED" | wc -l);
if [ "$newsuspended" != 0 ]; then
    echo -e "Users suspended: \033[1;31m$newsuspended\033[0m";
fi

if [ "$new_enabled" == "yes" ]; then
 newxs=$(egrep "BACKUP=0" /var/cpanel/users/* | grep ":BACK" | wc -l);
 echo -e "New Backup users disabled: \033[1;31m$newxs\033[0m";
 newen=$(egrep "BACKUP=1" /var/cpanel/users/* | grep ":BACK" | wc -l);
 echo -e "New Backup users enabled: \033[1;32m$newen\033[0m"
fi
}

function show_recent_errors() {
    # Errors from backup log directory
    echo -e "\n\033[36m[ Count of Recent Errors ]\033[0m";
    for i in `\ls $backlogdir`; do 
        echo -n $backlogdir"/"$i" Ended "; 
        \ls -lrth $backlogdir | grep $i | awk '{print $6" "$7" "$8}'; 
        \egrep -i "failed|error|load to go down|Unable" $backlogdir/$i | cut -c -180 | sort | uniq -c ;
    done | tail -2;
    # Errors from cPanel error log
    echo -e "\n/usr/local/cpanel/logs/error_log:"
    egrep "(warn|die|panic) \[backup" /usr/local/cpanel/logs/error_log | awk '{printf $1"] "; for (i=4;i<=20;i=i+1) {printf $i" "}; print ""}' | uniq -c | tail -3

    #any_ftp_backups=$(\grep 'disabled: 0' /var/cpanel/backups/*backup_destination 2>/dev/null)
    if [ -n "$any_ftp_backups" ]; then
        # Errors from FTP backups
        echo -e "\n/usr/local/cpanel/logs/cpbackup_transporter.log:"
        egrep '] warn|] err' /usr/local/cpanel/logs/cpbackup_transporter.log | tail -5
    fi
}

# Run all functions
check_new_backups
print_start_end_times 
print_num_expected_users
exceptions_heading
list_new_exceptions
show_recent_errors
echo; echo

