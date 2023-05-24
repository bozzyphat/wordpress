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
$dbserver="db-mysql-dev-auseast-001"
$restoreserver ="db-mysql-dev-auseast-$randomIdentifier"
$mysqlsku ="GP_Gen5_2"
$backupretention ="7"
$storagesize ="10240"
$login ="azureuser"



# Variable block for mysql
$secretName = "mysqlpass"
$akvName ="akv-wp-dev-aus"
$dbpassword = az keyvault secret show --name $SecretName --vault-name $akvName --query value -o tsv

# Create a mysql server in the resource group
# Name of a server maps to DNS name and is thus required to be globally unique in Azure.
Write-Output "Creating $restoreserver in $location..." | Green
az mysql server create --name $restoreserver --resource-group $resourceGroup --location "$location" --admin-user $login --admin-password $dbpassword --sku-name $mysqlsku --ssl-enforcement Disabled --backup-retention $backupretention --geo-redundant-backup Disabled --storage-size $storagesize --version 5.7

#Configuring a firewall rule for MySQl server  allow azure services
Write-Output  "Configuring a firewall rule for $restoreserver allow azure services" | Green
az mysql server firewall-rule create --resource-group $resourceGroup --server $restoreserver -n AllowAllWindowsAzureIps --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0


# Restore a server from backup to a new server
# To specify a specific point-in-time (in UTC) to restore from, use the ISO8601 format:
# restorePoint=“2021-07-09T13:10:00Z”
Write-Output "To specify a specific point-in-time (in UTC) to restore from, use the ISO8601 format with your local timezone: 2023-05-24T05:59:00Z "
$restorePoint = $secret = Read-Host 'Type in the restore point'

Write-Output  "Restoring data from $dbserver to $restoreServer" | Green
az mysql server restore --name $restoreServer --resource-group $resourceGroup --restore-point-in-time $restorePoint --source-server $dbserver

# echo "Deleting all resources"
# az group delete --name $resourceGroup -y