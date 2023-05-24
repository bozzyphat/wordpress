#Requires -RunAsAdministrator

function Green
{
    process { Write-Host $_ -ForegroundColor Green }
}


Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser


Write-Output "Login with Azure account" | Green
az login 

# Variable block
$location ="australiaeast"
$resourceGroup ="rg-wp-dev-auseast-001"
$login ="azureuser"

# Variable block for mysql login password
$secretName = "mysqlpass"
$akvName ="akv-wp-dev-aus"
$dbpassword = az keyvault secret show --name $SecretName --vault-name $akvName --query value -o tsv


#Variable to get the list of current web app
Write-Output "Current list of web app in the Resrouces group $resourceGroup" | Green
az webapp list -o table
$appname=Read-Host 'Type in the web app name will change the database'  

#Variable to get the list of current databse 
Write-Output "Current list of MySQL database in the Resrouces group $resourceGroup" | Green
az resource list -o table --query "[?type=='Microsoft.DBforMySQL/servers'].{name:name}"
$dbserver=Read-Host 'Type in the Mysql server going to be used' 


#Configure database variables in WordPress
#Write-Output "Configure WordPress-specific environment variables in database" | Green
az webapp config appsettings set --resource-group $resourceGroup --name $appname --settings WORDPRESS_DB_HOST="$dbserver".mysql.database.azure.com WORDPRESS_DB_USER=$login WORDPRESS_DB_PASSWORD=$dbpassword WORDPRESS_DB_NAME="wordpress" MYSQL_SSL_CA="BaltimoreCyberTrustroot.crt.pem"