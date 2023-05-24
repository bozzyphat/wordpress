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
    This script will set up WordPress using docker
        .\create-wordpress-docker-azure.ps1

Stage 4:
    *****Before running the PowerShell script, make sure you change the variable $dbserver value (the value is the name of the current running MYSQL database server)******
    Run the PowerShell script with Admin privileges:
    This script will restore the MYSQL database to the specific data within the retention range 
        .\restore-mysql-azure.ps1

