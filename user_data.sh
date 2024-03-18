# user_data.sh

#!/bin/bash
yum update -y
yum install -y httpd
echo "<h1>Welcome to my EC2 instance. I am from Terraform</h1>" > /var/www/html/index.html
systemctl start httpd
systemctl enable httpd