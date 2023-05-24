Stage 1:
    Install the Azure CLi and docker

Stage 2:
    Run the powershell script with Admin privileges:
    This script will set up Azure resouces group, Keyvault, MariaDb databse and VNet 
        powershell -ExecutionPolicy Bypass -File create-mariadb-azure-vnet.ps1
    
    In this scriot, there is a step you have to key in the password you will be using to access the databse in future


Stage 3:
