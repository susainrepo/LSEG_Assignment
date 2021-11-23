#!/bin/bash
  
#LSEG Assignment : SCRIPT_2
#Author : Susain Warshakoon
#Email : susain92@gmail.com
#Created on 2021-11-21

timestamp=$(date)
tdate=`date +%Y%m%d`

#############################################################
webserver_ip=13.234.206.224
email_address=esw.mydemos@gmail.com
workspace_path=/tmp/backup_workspace
log_file=Web_Server_Backup_Report_$tdate.log
#############################################################

echo $timestamp > $log_file;

##Part_1-Step4.1 and Step4.2## 
##Collecting Web Server content to one compressed file

sudo ssh -o StrictHostKeyChecking=No -i /root/key/key.pem ec2-user@$webserver_ip /bin/bash <<'EOT'
cd /tmp/workspace/;
sudo mkdir -p `date +%Y%m%d`;
sudo cp /var/www/html/index.html /var/log/httpd/access_log /var/log/httpd/error_log `date +%Y%m%d`;
sudo tar -czf DEMO_WEB_BACKUP_`date +%Y%m%d`.tar.gz `date +%Y%m%d`;
sudo scp -o StrictHostKeyChecking=No -i /root/key/key.pem DEMO_WEB_BACKUP_`date +%Y%m%d`.tar.gz ec2-user@3.7.157.75:/tmp/backup_workspace;
sudo rm -rf DEMO_WEB_BACKUP_`date +%Y%m%d`.tar.gz `date +%Y%m%d`;
EOT

##Part_1-Step4.3## 
##Upload the compressed file to S3 bucket
aws s3 cp "/tmp/backup_workspace/DEMO_WEB_BACKUP_`date +%Y%m%d`.tar.gz" s3://demobackup2021/ > /dev/null

##Part_1-Step4.4## 
##Verify compressed file upload to S3
function send_mail {
mail -s "$(echo -e "[ALERT] Backup Failed - $tdate")" -r "DEMO_ALERT<noreply-report>" $email_address
}

aws s3 ls s3://demobackup2021/DEMO_WEB_BACKUP_`date +%Y%m%d`.tar.gz > /dev/null
if [ $? -eq 0 ];then
   echo "[INFO] Backup File Uploaded to S3 Bucket" >> $log_file
   rm -rf DEMO_WEB_BACKUP_$tdate.tar.gz
else
   echo "[ERROR] Uploading Backup File to S3 Bucket Failed. Please Check." >> $log_file
   echo "`cat /tmp/backup_workspace/$log_file`" | send_mail
fi

echo "[INFO] Backup Validations Completed." >> $log_file

#Deleting log file.
rm -rf $log_file;
