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




#Variable to get the list of current web app
Write-Output "Current list of web app in the Resrouces group $resourceGroup" | Green
az webapp list -o table
$appname=Read-Host 'Type in the web app name will be restore'  

#Variable to get the list of current web app restore points 
Write-Output "Current list of restore points for web app $appname " | Green
az webapp config snapshot list --name $appname --resource-group $resourceGroup -o table
$restoretime=Read-Host 'Type in the selected snapshot time to be restore, follow with the result format 2023-05-24T22:45:17.0054237'  

#Restore the web app
Write-Output "Restore web app $appname to the restore point in time $restoretime, the restore point in time is in UTC" | Green
az webapp config snapshot restore --name $appname --resource-group $resourceGroup --time $restoretime