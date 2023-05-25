_______________________________________________________________________________________________________________________
</mark>Create WordPress app service on Azure</mark> 
_______________________________________________________________________________________________________________________
Stage 1:
    Install the Azure CLI and docker

    ****Run this command to allow remotely running command*** 
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

Stage 2:
    Run the PowerShell script with Admin privileges:
    This script will set up Azure resources group, Keyvault, Mysql database and configure MySQL firewall
        .\create-mysql-azure-firewall.ps1
    
    In this script, there is a step you have to key in the password you will be using to access the database in future

Stage 3:
    Run the PowerShell script with Admin privileges:
    This script will set up WordPress on the Azure web app using Docker
        .\create-wordpress-docker-azure.ps1


_______________________________________________________________________________________________________________________
Backup and restore MySQL database
_______________________________________________________________________________________________________________________
Stage 1:
    *****Make sure you type in the correct date format to restore the database, point-in-time (in UTC) to restore from, and use the ISO8601 format with your local timezone: 2023-05-24T05:59:00Z****

    Run the PowerShell script with Admin privileges:
    This script will restore the original MYSQL database to a new database server within the backup retention time (7 days) 
        .\restore-mysql-azure.ps1

Stage 2:
    Run the PowerShell script with Admin privileges:
    This script will allow you to change the WordPress database to the newly created restore database server
        .\change-wordpress-databse.ps1

_______________________________________________________________________________________________________________________
Backup and restore Azure Web App
________________________________________________________________________________________________________________________
Stage 1:
    Run the PowerShell script with Admin privileges:
    This script will restore the web app to the selected restore points
        .\restore-wordpress-azure.ps1
