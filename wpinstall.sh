#!/bin/bash

password="!g3mf1nd!@"
DB_HOST=localhost
DB_NAME=wp_%name%
DB_USER=wp_%name%
DB_PASS=`openssl rand -base64 32`
WWW_PATH=/backup/git/wordpress/%name%
WWW_URL=http://%name%.wp.gfbeta.net
WP_EMAIL=ainie@gemfind.com
WP_USER=gemfind.developer
WP_PASS=`openssl rand -base64 32`
SHOW_HELP=0
VALIDATION_MESSAGE=""
DATA_DIR=/var/www/builder/cms/wordpress
BASE=/backup/git/wordpress


# Functions

ok() { echo -e '\e[32m'$1'\e[m'; } # Green

nok() { echo -e '\e[31m'$1'\e[m'; }

readme() {
echo -e "\n\n#  $NAME" >> README.md
echo -e "\nInformation" >> README.md
echo -e "-" >> README.md
echo -e "\n* URL: http://$NAME.wp.gfbeta.net" >> README.md
echo -e "* Created at : $(date)" >> README.md
echo -e "\nBackend" >> README.md
echo -e "-" >> README.md
echo -e "\n* URL: http://$NAME.wp.gfbeta.net/wp-admin" >> README.md
echo -e "* Username : $WP_USER" >> README.md
echo -e "* Password : $WP_PASS" >> README.md
echo -e "\nDatabase" >> README.md
echo -e "-" >> README.md
echo -e "\n* URL: http://mysql.gemfind.com" >> README.md
echo -e "* Database : $DB_NAME" >> README.md
echo -e "* USer : $DB_USER" >> README.md
echo -e "* Password : $DB_PASS" >> README.md
echo -e "\n\nThese are the credentials that the project had during creation and may be subject to change." >> README.md
echo -e "Feel free to update this file(README.md) in the repository to keep them up to date." >> README.md
echo -e "\n\n" >> README.md
}

gitops()
{
git add . > /dev/null
git commit -m "Initial commit" > /dev/null
git push origin master > /dev/null
}


# Read command line options
index=0
options=$@
arguments=($options)


	for argument in $options
	do
    	index=`expr $index + 1`
    	value=${arguments[`expr $index`]}
    	case $argument in
        # Options
        # General
        -n | --name) NAME=$value;;
        -h | --help) SHOW_HELP=1;;
    	esac
	done

# Show help!
if [ $SHOW_HELP == 1 ]; then
    nok "\n! Usage is:"
    nok "./wpinstall.sh -n <project_name>"
    echo ""
    exit
fi

# Validate parameters

# General
if [[ -z $NAME ]]; then
    VALIDATION_MESSAGE="Usage is : wpinstall.sh -n <project_name>"
fi

if [[ -z $WWW_PATH ]]; then
    VALIDATION_MESSAGE="Configuration 'WWW_PATH' cannot be empty"
fi

# Database
if [[ -z $DB_NAME ]]; then
    VALIDATION_MESSAGE="Configuration 'DB_NAME' cannot be empty"
fi

if [[ -z $DB_HOST ]]; then
    VALIDATION_MESSAGE="Configuration 'DB_HOST' cannot be empty"
fi

if [[ -z $DB_USER ]]; then
    VALIDATION_MESSAGE="Configuration 'DB_USER' cannot be empty"
fi

if [[ -z $DB_PASS ]]; then
    VALIDATION_MESSAGE="Configuration 'DB_PASS' cannot be empty"
fi

if [[ -z $WP_EMAIL ]]; then
    VALIDATION_MESSAGE="Configuration 'WP_EMAIL' cannot be empty"
fi

if [[ -z $WP_USER ]]; then
    VALIDATION_MESSAGE="Configuration 'WP_USER' cannot be empty"
fi

if [[ -z $WP_PASS ]]; then
    VALIDATION_MESSAGE="Configuration 'WP_PASS' cannot be empty"
fi

# Print message if present
if [[ ! -z $VALIDATION_MESSAGE ]]; then
    nok "\n! $VALIDATION_MESSAGE"
    echo ""
    exit
fi


# Render name variables with the name variable
WWW_PATH=${WWW_PATH/\%name\%/$NAME}
WWW_URL=${WWW_URL/\%name\%/$NAME}
DB_NAME=${DB_NAME/\%name\%/$NAME}
DB_USER=${DB_USER/\%name\%/$NAME}

    # Check whether or not the user wants to continue
    read -p "Are you really sure that you want to continue y/n [n]? " -n 1
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        nok "* Installation aborted."
        exit 1
    fi


# Create the database if it doesn't exist
#############################################################
		if [ ! -d $WWW_PATH ]
                then
                cd $BASE
		ok "Cloning repo....."
                git clone ssh://git@git.gemfind.com:2014/Wordpress/$NAME.git > /dev/null	
			if [ $? != 0 ]; then
			nok "\nUnable to clone the project in working directory."
			nok "\nExiting !!."
			exit
			fi 
# Database creation starts
		echo "* Recreating database $DB_NAME..."
                MYSQL=`which mysql`
                Q1="CREATE DATABASE IF NOT EXISTS $DB_NAME;"
                Q2="GRANT ALL ON $DB_NAME.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
                Q3="FLUSH PRIVILEGES;"
                SQL="${Q1}${Q2}${Q3}"


                        DBEXISTS=$(mysql -uroot -p$password --batch --skip-column-names -e "SHOW DATABASES LIKE '"$DB_NAME"';" | grep "$DB_NAME" > /dev/null; echo "$?")

                        if [ $DBEXISTS -eq 0 ];then
                        nok "A database with the name $DB_NAME already exists. exiting"
                        exit
                        else

                        $MYSQL -uroot -p$password -e "$SQL"

                                if [ $? == 0 ];then
                                ok "Database $DB_NAME and user $DB_USER created with a password $DB_PASS"
                                else
                                nok "Database creation failed"
                                fi
                        fi
# Database creation ends

# File transfer begins.

		cd $WWW_PATH
		# add puller.php
                touch puller.php
                echo "<?php shell_exec( 'cd $WWW_PATH && git reset --hard HEAD && git pull' );?>" >> puller.php

                readme 
                rsync -az $DATA_DIR/* .
                wp core config --allow-root --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASS
                wp core install --allow-root --url=$WWW_URL --title=WordPress --admin_user=gemfind.developer --admin_password=$WP_PASS --admin_email=$WP_EMAIL

		if [ $? == 0 ];then
                ok "\n Wordpress installed successfully !."
		else
		nok "\n Wordpress installation failed. "
		exit
		fi  
else #Project directory exist. Condition.
nok "\n Project Directory <$NAME> already exist."
nok "\n Exiting !!!."
echo ""
exit

fi # If close after verifying working directory exist.
#####################################################################################

ok "\nPushing files to repo...."
gitops > /dev/null

				if [ $? == 0 ];then
                                ok "\nFiles pushed from working directory to repo."
				chown -R apache:apache $WWW_PATH
               			chown -R apache:apache $WWW_PATH/.git
				chown -R apache:apache $WWW_PATH/.git/* 
				nok "Website : http://$NAME.wp.gfbeta.net           
				nok "Remember to add webhook http://$NAME.wp.gfbeta.net/puller.php in gitlab magento project."
                                else
                                nok "SOMETHING WRONG !. PUSH failed. Please try manually."
                                fi





