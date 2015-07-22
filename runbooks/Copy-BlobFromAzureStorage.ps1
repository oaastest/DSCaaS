<# 
	This PowerShell script was automatically converted to PowerShell Workflow so it can be run as a runbook.
	Specific changes that have been made are marked with a comment starting with “Converter:”
#>
workflow Copy-BlobFromAzureStorage {
	
	# Converter: Wrapping initial script in an InlineScript activity, and passing any parameters for use within the InlineScript
	# Converter: If you want this InlineScript to execute on another host rather than the Automation worker, simply add some combination of -PSComputerName, -PSCredential, -PSConnectionURI, or other workflow common parameters (http://technet.microsoft.com/en-us/library/jj129719.aspx) as parameters of the InlineScript
	inlineScript {
		﻿workflow Copy-BlobFromAzureStorage { 
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
	}
}