#Task2
#Performing an update of the package details and the package list at the start of the script

echo "Performing an update of the package details and the package list at the start of the script"

sudo apt update -y

#Initializing a variable of my name for log generation and S3 bucket storage
myName='Yatin'
s3Bucket='upgrad-yatin'

#Checking if Apache2 is installed in the system and storing it in variable

apacheInst=$(dpkg --get-selections | grep -m1 "apache2" | awk '{print $1}')

#If apache is not installed, then the above command will return a blank value. 
if [ "$apacheInst" = "apache2" ]
then 
	echo "Apache2 is already installed in the system. Skipping this step"
	
else
	echo "Apache2 is not installed in the system. Installing Apache2 now.."
	sudo apt install apache2 -y
	echo "Apache2 package has been successfully installed"
fi

#Checking if Apache2 is active in the system and storing it in variable
apacheAct=$(systemctl is-active apache2 | awk '{print $1}')

if [ "$apacheAct" = "active" ]
then
	echo "Apache2 is already running. Skipping this step"
else
	echo "Apache2 is not running. Starting the Apache2 service now.."
	sudo systemctl start apache2
	echo "Apache2 has has been successfully started"
fi 

#Checking if Apache2 is active in the system and storing it in variable
apacheEnb=$(systemctl is-enabled apache2 | awk '{print $1}')

if [  "$apacheEnb" = "enabled" ]
then
	echo "Apache2 is already enabled. Skipping this step.."
else
	echo "Apache2 is not enabled yet. Enabling Apache2 now.."
	sudo systemctl enable apache2
	echo "Apache2 has been successfully enabled."
fi

#Executing the timestamp format command and storing it in variable
timestampVar=$(date '+%d%m%Y-%H%M%S')

#Compressing the files ending with .log format and moving it to /tmp folder
tar -cvf $myName-httpd-logs-$timestampVar.tar /var/log/apache2/*.log
mv $myName-httpd-logs-$timestampVar.tar /tmp

#Moving the created tar log files to S3 bucket
aws s3 \
cp /tmp/$myName-httpd-logs-$timestampVar.tar \
s3://$s3Bucket/$myName-httpd-logs-$timestampVar.tar
