<?php
// ADD NEW ADMIN USER TO WORDPRESS
// ----------------------------------
// Put this file in your Wordpress root directory and run it from your browser.
// Delete it when you're done.



//pw generator 
			function mk_pw($length = 12) {

			$characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-+=_,!@$#*%[]{}";

			$pw = '';

			for ($i = 0; $i < $length; $i++) {

			$pw .= $characters[mt_rand(0, strlen($characters) - 1)];

			}

			return $pw;

			}

require_once('wp-blog-header.php');
require_once('wp-includes/registration.php');

// ----------------------------------------------------
// CONFIG VARIABLES
// Make sure that you set these before running the file.
$newusername = 'hackguard';
$newpassword = mk_pw();
$newemail = 'jim@hackguard.com';
// ----------------------------------------------------
	// Check that user doesn't already exist
	if ( !username_exists($newusername) && !email_exists($newemail) )
	{
		// Create user and set role to administrator
		$user_id = wp_create_user( $newusername, $newpassword, $newemail);
		if ( is_int($user_id) )
		{
			$path = $_SERVER['SCRIPT_FILENAME'];
			$wp_user_object = new WP_User($user_id);
			$wp_user_object->set_role('administrator');
			echo 'User: hackguard Password: '.$newpassword.'';
			shell_exec('rm -f '.$path);
			
		}
		else {
			echo 'Error with wp_insert_user. No users were created.';
		}
	}
	else {
		echo 'This user or email already exists. Nothing was done.';
	}
