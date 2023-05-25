Create Wordpress app service on Azure 
Stage 1:
    Install the Azure CLI and docker

    ****Run this command to allow remotely running command*** 
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

Stage 2:
    Run the PowerShell script with Admin privileges:
    This script will set up Azure resources group, Keyvault, Mysql database and configure MySQL firewall
        .\create-mysql-azure-firewall.ps1
    
    In this script, there is a step you have to key in the password you will be using to access the databse in future

Stage 3:
    Run the PowerShell script with Admin privileges:
    This script will set up WordPress on Azure web app using docker
        .\create-wordpress-docker-azure.ps1



Backup and restore MYSQl databse
Stage 1:
    *****Make sure you type in the correct date format to restore the databse, point-in-time (in UTC) to restore from, use the ISO8601 format with your local timezone: 2023-05-24T05:59:00Z****

    Run the PowerShell script with Admin privileges:
    This script will restore the original MYSQL database to new databse sever within the backup retention time (7days) 
        .\restore-mysql-azure.ps1

Stage 2:
    Run the PowerShell script with Admin privileges:
    This script will allow you to chaneg the WordPress database to the newly created restore databse server
        .\change-wordpress-databse.ps1

