workflow Copy-GithubRepository 
{ 
    param( 
       [Parameter(Mandatory=$True)] 
       [string] $Name, 
        
       [Parameter(Mandatory=$True)] 
       [string] $Author, 
        
       [Parameter(Mandatory=$False)] 
       [string] $Branch = "master", 
        
       [Parameter(Mandatory=$False)] 
       [string] $GithubTokenVariableAssetName = "GithubToken" 
    ) 
     
    $ZipFile = "C:\$Name.zip" 
    $OutputFolder = "C:\$Name\$Branch" 
     
    $Token = Get-AutomationVariable -Name $GithubTokenVariableAssetName 
     
    if(!$Token) { 
        throw("'$GithubTokenVariableAssetName' variable asset does not exist or is empty.") 
    } 
 
    $RepositoryZipUrl = "https://api.github.com/repos/$Author/$Name/zipball/$Branch" 
 
    # download the zip 
    Invoke-RestMethod -Uri $RepositoryZipUrl -Headers @{"Authorization" = "token $Token"} -OutFile $ZipFile 
     
    # extract the zip 
    InlineScript {         
        New-Item -Path $using:OutputFolder -ItemType Directory | Out-Null 
         
        [System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null 
        [System.IO.Compression.ZipFile]::ExtractToDirectory($using:ZipFile, $using:OutputFolder) 
    } 
 
    # remove zip 
    Remove-Item -Path $ZipFile -Force 
     
    #output the path to the downloaded repository 
    (ls $OutputFolder)[0].FullName 
}