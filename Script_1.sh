#!/bin/bash

#LSEG Assignment : SCRIPT_1
#Author : Susain Warshakoon
#Email : susain92@gmail.com
#Created on 2021-11-21

timestamp=$(date)
tdate=`date +%Y%m%d`

#Web Server EC2 Details
webserver_ip=13.234.206.224
webserver_url="http://13.234.206.224"

#RDS MySQL DB Details
db_host=demo-db.cwyseegjifvk.ap-south-1.rds.amazonaws.com
db_port=3306
db_user=admin
db_pw=Admin2021
db_name=DEMO
table_name=DEMO_STATS

workspace_path=/tmp/workspace
email_address=esw.mydemos@gmail.com
log_file=Web_Server_HealthCheck_Report_$tdate.log

echo $timestamp > $log_file;

##Part_1-Step3.1## 
##Web Server Status Check
ssh -o StrictHostKeyChecking=No -i /root/key/key.pem ec2-user@$webserver_ip 'pgrep httpd > /dev/null'
if [ $? -eq 0 ];then
        echo "[INFO] Httpd Service is active." >> $log_file
	service_status="Up"
else
        echo "[INFO] Httpd Service is inactive(dead)." >>  $log_file
	service_status="Down. Starting now."
        ssh -o StrictHostKeyChecking=No -i /root/key/key.pem ec2-user@$webserver_ip 'sudo systemctl start httpd'
	ssh -o StrictHostKeyChecking=No -i /root/key/key.pem ec2-user@$webserver_ip 'pgrep httpd > /dev/null'
	if [ $? -eq 0 ];then
		echo "[INFO] Httpd Service started successfully." >> $log_file
	else
		echo "[ERROR] Httpd Service is not starting. Please Check." >>  $log_file
	fi
fi


##Part_1-Step3.2## 
##Web Server Content Check
valid_content="Hello World"
current_content=$(curl -s $webserver_url)
status=$(curl --write-out '%{http_code}' -s -o /dev/null $webserver_url)

if [[ "$current_content" == "$valid_content" ]] && [[ "$status" == "200" ]]
then
  echo "[INFO] HTTP Code 200 and Content Success.">> $log_file
  status_code="200"
  content="Hello World"
else
  echo "[ERROR] Web Server is not working as expected. Response is invalid. Please Check.">> $log_file
  status_code=$status
  content="Invalid Response"
fi


##Part_1-Step3.3## 
##Save Results to DB

mysql -h $db_host -P $db_port -u$db_user -p$db_pw<<EOF
use $db_name;
insert into $table_name (\`service_status\`, \`status_code\`, \`content\`, \`timestamp\`) VALUES ("$service_status", "$status_code", "$content" , "$timestamp");
EOF
if [ $? -eq 0 ];
then
    echo "[INFO] Health Check Status Record Inserted to the DB Successfully." >> $log_file
else
    echo "[ERROR] Failed to Insert Data." >> $log_file
fi

##Part_1-Step3.4## 
##Sending Mail Report

function send_mail {
mail -s "$(echo -e "[ALERT] Web Server Health Check Failed - $tdate")" -r "DEMO_ALERT<noreply-report>" $email_address
}

cat /tmp/workspace/$log_file | grep 'ERROR' > /dev/null
if [ $? -eq 0 ];
then
	echo "[ERROR] Web Server Health Check Failed." >> $log_file
	echo "`cat /tmp/workspace/$log_file`" | send_mail
else
	echo "[INFO] HealthCheck Completed Successfully." >> $log_file
fi	

echo "[INFO] HealthCheck Completed." >> $log_file

#Deleting log file.
rm -rf $log_file;
