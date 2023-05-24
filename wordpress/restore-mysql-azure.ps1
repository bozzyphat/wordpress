#Requires -RunAsAdministrator

function Green
{
    process { Write-Host $_ -ForegroundColor Green }
}


Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser


Write-Output "Login with Azure account" | Green
az login 

# Variable block
$randomIdentifier = Get-Random -Maximum 100
$location ="australiaeast"
$resourceGroup ="rg-wp-dev-auseast-001"
$tag ="wordpress-service"
$restoreserver ="mysql-dev-auseast-$randomIdentifier"
$mysqlsku ="GP_Gen5_2"
$backupretention ="7"
$storagesize ="10240"
$login ="azureuser"


#Variable to get the list of current databse 
Write-Output "Current list of MySQL database in the Resrouces group $resourceGroup" | Green
az resource list -o table --query "[?type=='Microsoft.DBforMySQL/servers'].{name:name}"
$dbserver=Read-Host 'Type in the original Mysql server will be restore' 

# Restore a server from backup to a new server
# To specify a specific point-in-time (in UTC) to restore from, use the ISO8601 format:
# restorePoint=“2021-07-09T13:10:00Z”
Write-Output "To specify a specific point-in-time (in UTC) to restore from, use the ISO8601 format: 2023-05-24T05:59:00Z " | Green
$restorePoint = Read-Host 'Type in the restore point'

Write-Output  "Restoring data from $dbserver to $restoreServer" | Green
az mysql server restore --name $restoreServer --resource-group $resourceGroup --restore-point-in-time $restorePoint --source-server $dbserver

#Configuring a firewall rule for MySQl server  allow azure services
Write-Output  "Configuring a firewall rule for $restoreserver allow azure services" | Green
az mysql server firewall-rule create --resource-group $resourceGroup --server $restoreserver -n AllowAllWindowsAzureIps --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

# echo "Deleting all resources"
# az group delete --name $resourceGroup -y