#Requires -RunAsAdministrator

function Green
{
    process { Write-Host $_ -ForegroundColor Green }
}


Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser


Write-Output "Login with Azure account" | Green
az login 

# Variable block
$resourceGroup ="rg-wp-dev-auseast-001"
$login ="azureuser"
$randomIdentifier = Get-Random -Maximum 100
$restoreserver ="mysql-dev-auseast-$randomIdentifier"


#Variable to get the list of current web app
Write-Output "Current list of web app in the Resrouces group $resourceGroup" | Green
az webapp list -o table
$appname=Read-Host 'Type in the web app name will be restore'  


#Variable to get the list of current databse linked with the web app
Write-Output "Current MySQL database using by $appname" | Green
az webapp config appsettings list --name $appname --resource-group $resourceGroup -o table --query "[?name=='WORDPRESS_DB_HOST'].{name:value}" 
$dbserver=Read-Host 'Type in the original Mysql server curretly using by web app, make sure only use the databse name with out .mysql.database.azure.com' 

#Variable to get the list of current web app restore points 
Write-Output "Current list of restore points for web app $appname, the restore point time is in UTC " | Green
az webapp config snapshot list --name $appname --resource-group $resourceGroup -o table
$restoretime=Read-Host 'Type in the selected snapshot time to be restore, follow with the result format 2023-05-24T22:45:17.0054237' 


# Restore a database server from backup to a new server
Write-Output  "Restoring data from $dbserver to $restoreServer follow the time $restoretime" | Green
az mysql server restore --name $restoreServer --resource-group $resourceGroup --restore-point-in-time "$restoretime" --source-server $dbserver

#Configuring a firewall rule for MySQl server  allow azure services
Write-Output  "Configuring a firewall rule for $restoreserver allow azure services" | Green
az mysql server firewall-rule create --resource-group $resourceGroup --server $restoreserver -n AllowAllWindowsAzureIps --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

#Restore the web app
Write-Output "Restore web app $appname to the restore point in time $restoretime" | Green
az webapp config snapshot restore --name $appname --resource-group $resourceGroup --time $restoretime


# Variable block for mysql login password
$secretName = "mysqlpass"
$akvName ="akv-wp-dev-aus"
$dbpassword = az keyvault secret show --name $SecretName --vault-name $akvName --query value -o tsv


#Configure database variables in WordPress
Write-Output "Change Wordpress web app databse to $restoreServer" | Green
az webapp config appsettings set --resource-group $resourceGroup --name $appname --settings WORDPRESS_DB_HOST="$restoreServer".mysql.database.azure.com WORDPRESS_DB_USER=$login WORDPRESS_DB_PASSWORD=$dbpassword WORDPRESS_DB_NAME="wordpress" MYSQL_SSL_CA="BaltimoreCyberTrustroot.crt.pem"