#Task2

#Performing an update of the package details and the package list at the start of the script

echo "Performing an update of the package details and the package list at the start of the script"

sudo apt update -y

#Initializing a variable of my name for log generation and S3 bucket storage
myName='Yatin'
s3Bucket='upgrad-yatin'

#Checking if "Apache2" is installed in the system and storing it in variable

apacheInst=$(dpkg --get-selections | grep -m1 "apache2" | awk '{print $1}')
echo "Checking if Apache2 is installed.."
#If apache is installed, then the above command will return "apache2" as a text value. 
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
echo "Checking if Apache2 is active.."

if [ "$apacheAct" = "active" ]
then
	echo "Apache2 is already running. Skipping this step"
else
	echo "Apache2 is not running. Starting the Apache2 service now.."
	sudo systemctl start apache2
	echo "Apache2 has has been successfully started"
fi 

echo "Checking if Apache2 is enabled.."
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
echo "Compressing the log files"
tar -cvf $myName-httpd-logs-$timestampVar.tar /var/log/apache2/*.log
mv $myName-httpd-logs-$timestampVar.tar /tmp
echo "Log file compression succesful"

#Installing AWS CLI dependencies
echo "Installing AWS CLI"
sudo apt update -y
sudo apt install awscli -y
echo "AWS CLI installed"

#Moving the created tar log files to S3 bucket
echo "Moving compressed logs in .tar format to S3 bucket"
aws s3 \
cp /tmp/$myName-httpd-logs-$timestampVar.tar \
s3://$s3Bucket/$myName-httpd-logs-$timestampVar.tar
echo "Successfully uploaded the log files in .tar format to S3 bucket named: $s3Bucket"



#Task 3

#Creating FileName1 to check if it exists, creating FileName2 to create the file in the directory if it does not exist
FileName1=/var/www/html/inventory.html
FileName2=/var/www/html/inventory.html
echo "Checking if inventory.html exists under /var/www/html"
#Checking if file named Inventory.html exists
if [ -f "$FileName1" ]
then
    echo "$FileName1 already exists."
else
    echo -e "$FileName1 does not exist \n Creating the file.."

#Creating the inventory.html file and the appending the header file to it. 
    sudo touch $FileName2
    echo -e "\n Log Type    &nbsp;&nbsp;&nbsp;&nbsp;         Date Created      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;         Type     &nbsp;&nbsp;&nbsp;&nbsp;        Size \n <br>" > $FileName2
    echo -e "$FileName2 successfully created"
fi

#Initializing empty variables in order to iterate a for loop.
nameOfFile=''
timeStampofFile=''
typeOfFile=''
SizeOfFile=''

echo "Appending file details to inventory.html"
#Iteratively extracting and printing the filename, timestamp, type of file & size of file to Inventory.html
for fileVar in /tmp/*.tar
do
	#Storing filename to tmpVar
	tmpVar=$fileVar
	#Extracting name of the file and storing it in variable
	nameOfFile=$(echo "$tmpVar" | awk -F'[-]' '{print $2 $3}')
	#Extracting timestamp of the file and storing it in variable
	timeStampofFile=$(echo "$tmpVar" | awk -F'[-.]' '{print $4 $5}')
	#Extracting type of the file (extension) and storing it in variable
	typeOfFile=$(echo "$tmpVar" | awk -F'[.]' '{print $2}')
	#Extracting size of the file and storing it in variable
	SizeOfFile=$(du -s -h $tmpVar | awk '{ print $1 }')
	#Printing the aforementioned details in inventory.html file by appending it, not erasing or replacing any data stored previously

             echo -e "$nameOfFile    &nbsp;&nbsp;&nbsp;&nbsp;      $timeStampofFile       &nbsp;&nbsp;&nbsp;&nbsp;         $typeOfFile     &nbsp;&nbsp;&nbsp;&nbsp;   $SizeOfFile \n <br>" >> /var/www/html/inventory.html

done
#For loop closed
echo "Appending of details to file inventory.html completed successfully"

#Creating a cron job to run once everyday
#Creating two variables, one to check if the cron job already exists and the second one to create the file if it does not exist
cronJobVar=/etc/cron.d/automation
cronJobVar2=/etc/cron.d/automation
echo "Checking if Cron job is scheduled.."
if [ -f "$cronJobVar" ]
then
        echo "Cron job is already scheduled. Skipping this step.."
else
        echo "Cron job is not scheduled \n Scheduling the cron job now.."
        sudo touch $cronJobVar2
        echo "0 0 * * * root /root/Automation_Project/Automation.sh" > /etc/cron.d/automation
        echo "Cron job has been scheduled successfully"
fi
