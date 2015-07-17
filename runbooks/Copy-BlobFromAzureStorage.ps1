workflow Copy-BlobFromAzureStorage { 
    param 
    ( 
        [parameter(Mandatory=$True)]  
        [String]  
        $AzureSubscriptionName,  
  
        [parameter(Mandatory=$True)]  
        [PSCredential]  
        $AzureOrgIdCredential,  
 
        [parameter(Mandatory=$True)] 
        [String] 
        $StorageAccountName, 
 
        [parameter(Mandatory=$True)] 
        [String] 
        $ContainerName, 
 
        [parameter(Mandatory=$True)] 
        [String] 
        $BlobName, 
 
        [parameter(Mandatory=$False)] 
        [String] 
        $PathToPlaceBlob = "C:\" 
    ) 
 
    $Null = Add-AzureAccount -Credential $AzureOrgIdCredential  
    $Null = Select-AzureSubscription -SubscriptionName $AzureSubscriptionName 
 
    Write-Verbose "Downloading $BlobName from Azure Blob Storage to $PathToPlaceBlob" 
 
    Set-AzureSubscription ` 
        -SubscriptionName $AzureSubscriptionName ` 
        -CurrentStorageAccount $StorageAccountName 
 
    $blob =  
        Get-AzureStorageBlobContent ` 
            -Blob $BlobName ` 
            -Container $ContainerName ` 
            -Destination $PathToPlaceBlob ` 
            -Force 
 
    try { 
        Get-Item -Path "$PathToPlaceBlob\$BlobName" -ErrorAction Stop 
    } 
    catch { 
        Get-Item -Path $PathToPlaceBlob 
    } 
}
