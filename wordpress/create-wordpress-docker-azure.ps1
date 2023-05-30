#Requires -RunAsAdministrator

function Green
{
    process { Write-Host $_ -ForegroundColor Green }
}

Write-Output "Login with Azure account" | Green
az login 

# Variable block
$location ="australiaeast"
$resourceGroup ="rg-wp-dev-auseast-001"
$appservice="app-wp-dev-auseast-001"
$appsku ="S2"
$appname="wp-dev-001"
#$vNet ="vNet-wp-dev-auseast-001"
#$subnet ="subnet-wp-dev-auseast-001"
$login ="azureuser"
$secretName = "mysqlpass"
$akvName ="akv-wp-dev-aus"
$dbpassword = az keyvault secret show --name $SecretName --vault-name $akvName --query value -o tsv
$wpdbserver ="mysql-dev-auseast-001.mysql.database.azure.com"


#Create an Azure App Service plan
Write-Output "Create an Azure App Service plan $appservice in Resources group $resourceGroup..." | Green
az appservice plan create --name $appservice --resource-group $resourceGroup --sku $appsku --location "$location" --is-linux


#Create a Docker Compose app
Write-Output "Create a Docker Compose app $appname Azure App Service plan $appservice..." | Green
az webapp create --resource-group $resourceGroup --plan $appservice --name $appname --multicontainer-config-type compose --multicontainer-config-file docker-compose.yml

#Configure database variables in WordPress
Write-Output "Configure WordPress-specific environment variables in database" | Green
az webapp config appsettings set --resource-group $resourceGroup --name $appname --settings WORDPRESS_DB_HOST="$wpdbserver" WORDPRESS_DB_USER=$login WORDPRESS_DB_PASSWORD=$dbpassword WORDPRESS_DB_NAME="wordpress" MYSQL_SSL_CA="BaltimoreCyberTrustroot.crt.pem"

#Add persistent storage for web app
Write-Output "Add persistent storage for $appname Azure App Service plan $appservice..." | Green
az webapp config appsettings set --resource-group $resourceGroup --name $appname --settings WEBSITES_ENABLE_APP_SERVICE_STORAGE=TRUE


# echo "Deleting all resources"
# az group delete --name $resourceGroup -y