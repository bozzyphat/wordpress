#Requires -RunAsAdministrator

function Green
{
    process { Write-Host $_ -ForegroundColor Green }
}

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Variable block
$location ="australiaeast"
$resourceGroup ="rg-wp-dev-auseast-001"
$appservice="app-wp-dev-aueast-001"
$appsku ="S1"
$appname="wp-dev-001"
$vNet ="vNet-wp-dev-auseast-001"
$subnet ="subnet-wp-dev-auseast-001"
$login ="azureuser"
$dbpassword = az keyvault secret show --name $SecretName --vault-name $akvName --query value -o tsv

$akvName ="akv-wp-dev-aus"
$akvsku ="standard"
$tag ="wordpress-service"
$server ="db-mysql-dev-auseast-001"

$backupretention ="7"
$storagesize ="10240"
$vNetAddressPrefix ="10.0.0.0/16"
$subnetAddressPrefix ="10.0.1.0/24"
$rule ="rule-wp-dev-auseast"


Write-Output "Login with Azure account" | Green
az login 


#Create an Azure App Service plan
Write-Output "Create an Azure App Service plan $appservice in Resources group $resourceGroup..." | Green
az appservice plan create --name $appservice --resource-group $resourceGroup --sku $appsku -location $location --is-linux


#Create a Docker Compose app
Write-Output "Create a Docker Compose app $appname Azure App Service plan $appservice..." | Green
az webapp create --resource-group $resourceGroup --plan $appservice --name $appname --multicontainer-config-type compose --multicontainer-config-file docker-compose.yml

#Add persistent storage for web app
Write-Output "Add persistent storage for $appname Azure App Service plan $appservice..." | Green
az webapp config appsettings set --resource-group $resourceGroup --name $appname --settings WEBSITES_ENABLE_APP_SERVICE_STORAGE=TRUE

#Add the Vnet to webapp
Write-Output "Adding web app to $subnet in $vNet" | Green
az webapp vnet-integration add -g $resourceGroup -n $appname --vnet $vNet --subnet $subnet

#Configure database variables in WordPress
Write-Output "Configure WordPress-specific environment variables in database" | Green
az webapp config appsettings set --resource-group $resourceGroup --name $appname --settings WORDPRESS_DB_HOST="db-mysql-dev-auseast-001.mysql.database.azure.com" WORDPRESS_DB_USER=$login WORDPRESS_DB_PASSWORD=$dbpassword WORDPRESS_DB_NAME="wordpress" MYSQL_SSL_CA="BaltimoreCyberTrustroot.crt.pem"







# Create Azure KeyVault
Write-Output "Creating KeyValut name $akvName in Resources group $resourceGroup..." | Green
az keyvault create --location $location --name $akvName --resource-group $resourceGroup --sku $akvsku

# Set secret for mysql Database Login Password
Write-Output "Creating mysql Database Login Password in Keyvault $akvName..." | Green

# Variable block for Keyvault Secret
$secretName = "mysqlpass"
$secret = Read-Host 'Type in the password You want to use for mysql Database Login' -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret)
$plainSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
# Set the value for Secret (password)
az keyvault secret set --name $secretName --vault-name $akvName --value $plainSecret


# Variable block for mysql
$login ="azureuser"
$dbpassword = az keyvault secret show --name $SecretName --vault-name $akvName --query value -o tsv
#Write-Output "The password to login  for mysql Database is $dbpassword" | Green


# Create a mysql server in the resource group
# Name of a server maps to DNS name and is thus required to be globally unique in Azure.
Write-Output "Creating $server in $location..." | Green
az mysql server create --name $server --resource-group $resourceGroup --location "$location" --admin-user $login --admin-password $dbpassword --sku-name $mysqlsku --ssl-enforcement Disabled --backup-retention $backupretention --geo-redundant-backup Disabled --storage-size $storagesize


# Get available service endpoints for Azure region output is JSON
Write-Output "List of available service endpoints for $location" | Green
az network vnet list-endpoint-services --location "$location"

# Add Azure SQL service endpoint to a subnet while creating the virtual network
Write-Output "Adding service endpoint to $subnet in $vNet" | Green
az network vnet create --resource-group $resourceGroup --name $vNet --address-prefixes $vNetAddressPrefix --location "$location"

# Creates the service endpoint
Write-Output "Creating a service endpoint to $subnet in $vNet" | Green
az network vnet subnet create --resource-group $resourceGroup --name $subnet --vnet-name $vNet --address-prefix $subnetAddressPrefix --service-endpoints Microsoft.SQL

# View service endpoints configured on a subnet
Write-Output "Viewing the service endpoint to $subnet in $vNet" | Green
az network vnet subnet show --resource-group $resourceGroup --name $subnet --vnet-name $vNet

# Create a VNet rule on the server to secure it to the subnet
# Note: resource group (-g) parameter is where the database exists.
# VNet resource group if different should be specified using subnet id (URI) instead of subnet, VNet pair.
Write-Output "Creating a VNet rule on $server to secure it to $subnet in $vNet" | Green
az mysql server vnet-rule create --name $rule --resource-group $resourceGroup --server $server --vnet-name $vNet --subnet $subnet
# </FullScript>

# Create wordpress databse on the databse server
Write-Output "Create wordpress databse on the databse server $server" | Green
az mysql db create --resource-group $resourceGroup --server-name $server --name wordpress

#Configure database variables in WordPress
Write-Output "Configure WordPress-specific environment variables in database" | Green

# echo "Deleting all resources"
# az group delete --name $resourceGroup -y