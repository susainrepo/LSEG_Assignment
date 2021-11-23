# LSEG_Assignment
London Stock Exchange Group Interview Take Home Assignment.

=======================================================================
Health Check Automation (script_1.sh)
=======================================================================
Functionality : Health check automation shell script script_1.sh is setup in demo-control server. This configured with the below functionality.
	- Checking if Web server is running and start it if it is down.
	- Checking if the web server is serving the expected content which is "Hello World" with the status code.
	- Saving the results of this script in MySQL database with the timestamps.
	- To ensure availability and reliability of this setup, it’s configured to run in every 5 minutes.
	- Notifying the App Support team if the script detects any errors via an email.

Below are the requirements to run script script_1.sh.
	1. Copy the key.pem file to demo-control in /root/key and give only read permission to it using the below command.
			#chmod 400 /root/key/key.pem
	2. Copy Script_1.sh in /tmp/workspace location and provide the necessary permissions to the workspace directory and the script using the below commands.
			#mkdir –p /tmp/workspace
			#chmod –R 750 /tmp/workspace
			#chmod 750 /tmp/workspace/Script_1.sh
	3. Add the script to crontab so it will run every 5 minutes.
			#crontab –e
			Add the below line
			*/5 * * * * /tmp/workspace/Script_1.sh
      
=======================================================================
Health Check Automation (script_1.sh)
=======================================================================
Backup Automation (script_2.sh)
Functionality : 
Backup automation shell script script_2.sh is setup in demo-control server. This configured with the below functionality.
	- Collecting log files and content of the web server (index.html, access_log, error_log) daily and create one compressed file named DEMO_WEB_BACKUP_YYYYMMDD.tar.gz
	- Moving this backup file to the same location as the script is running which is demo-control.
	- Uploading the backup file to a S3 bucket daily at 10:00PM.
	- If it is successful, remove the compressed file from the script location, and if not informing the application support team via an email.

Below are the requirements to run script script_2.sh.
	1. Copy the key.pem file to demo-control and in demo-web in /root/key and give only read permission to it using the below command.
			#chmod 400 /root/key/key.pem
	2. Copy Script_2.sh in /tmp/backup_workspace location and provide the necessary permissions to the backup_workspace directory so that the ec2-user can copy content to it and to the script using the below commands.
			#mkdir –p /tmp/backup_workspace
			#chown –R ec2-user:ec2-user /tmp/backup_workspace
			#chmod –R 750 /tmp/backup_workspace
			#chown root:root /tmp/backup_workspace/Script_2.sh
			#chmod 750 /tmp/workspace/Script_2.sh
	3. Add the script to crontab so it will run daily at 10PM.
			#crontab –e
			Add the below line
			0 22 * * * /tmp/backup_workspace/Script_2.sh
