#Requires -RunAsAdministrator

function Green
{
    process { Write-Host $_ -ForegroundColor Green }
}

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Variable block
$randomIdentifier ="$RANDOM*$RANDOM"
$location ="australiaeast"
$resourceGroup ="rg-wp-dev-auseast-001"
$akvName ="akv-wp-dev-aus"
$akvsku ="standard"
$tag ="wordpress-service"
$server ="db-mariadb-dev-auseast-001"
$mariadbsku ="GP_Gen5_2"
$backupretention ="7"
$storagesize ="10240"
$rule ="rule-wp-dev-auseast-001"
# Specify appropriate IP address values for your environment
# to limit / allow access to the MariaDB server
startIp=0.0.0.0
endIp=0.0.0.0


#Install Azure CLI
Write-Output "Install Azure CLI" | Green
winget install azure-cli

#Install Azure Powershell
Write-Output "Install Azure Powershell" | Green
Install-Module -Name Az -Repository PSGallery 


Write-Output "Using resource group $resourceGroup with login: $login, password: $password..." | Green
az login 

# Create a resource group
Write-Output "Creating $resourceGroup in $location..." | Green
az group create --name $resourceGroup --location "$location" --tags $tag

# Create Azure KeyVault
Write-Output "Creating KeyValut name $akvName in Resources group $resourceGroup..." | Green
az keyvault create --location $location --name $akvName --resource-group $resourceGroup --sku $akvsku

# Set secret for MariaDB Database Login Password
Write-Output "Creating MariaDB Database Login Password in Keyvault $akvName..." | Green

# Variable block for Keyvault Secret
$secretName = "mariadbpass"
$secret = Read-Host 'Type in the password You want to use for MariaDB Database Login' -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret)
$plainSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
# Set the value for Secret (password)
az keyvault secret set --name $secretName --vault-name $akvName --value $plainSecret


# Variable block for mariaDB
$login ="azureuser"
$dbpassword = az keyvault secret show --name $SecretName --vault-name $akvName --query value -o tsv
#Write-Output "The password to login  for MariaDB Database is $dbpassword" | Green



# Create a MariaDB server in the resource group
# Name of a server maps to DNS name and is thus required to be globally unique in Azure.
Write-Output "Creating $server in $location..." | Green
az mariadb server create --name $server --resource-group $resourceGroup --location "$location" --admin-user $login --admin-password $dbpassword --sku-name $mariadbsku --ssl-enforcement Disabled --backup-retention $backupretention --geo-redundant-backup Disabled --storage-size $storagesize

# Configure a firewall rule for the server 
Write-Output  "Configuring a firewall rule for $server for the IP address range of $startIp to $endIp" | Green
az mariadb server firewall-rule create --resource-group $resourceGroup --server $server --name AllowIps --start-ip-address $startIp --end-ip-address $endIp
# </FullScript>

# </FullScript>

# echo "Deleting all resources"
# az group delete --name $resourceGroup -y