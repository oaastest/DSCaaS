workflow Sync-GithubRunbooks
{
    param (
       [Parameter(Mandatory=$True)]
       [string] $Repo,

       [Parameter(Mandatory=$True)]
       [string] $OAuthToken,

       [Parameter(Mandatory=$False)]
       [string] $Branch = "master",

       [Parameter(Mandatory=$False)]
       [string] $FolderPath = "runbooks"
    )

    $psExtension = ".ps1"

    # headers parameters
    $headers = @{"Authorization" = "token $OAuthToken"};
    
    # get username
    $metadata = Invoke-RestMethod -Method Get -Uri "https://api.github.com/user" -Headers $headers;
    $username = $metadata.login;

    # get branch sha
    $Uri = "https://api.github.com/repos/" + $username + "/" + $Repo + "/git/refs/heads/" + $Branch;
    $results = Invoke-RestMethod -Method Get -Uri $Uri -Headers $headers;
    $branchSha = $results.object.sha;

    #get sha of the last commit from this branch
    $Uri = "https://api.github.com/repos/" + $username + "/" + $Repo + "/commits?sha=" + $branchSha;
    $commits = Invoke-RestMethod -Method Get -Uri $Uri -Headers $headers;
    $commitSha = $commits[0].sha;

    # get sha of branch's tree
    $Uri = "https://api.github.com/repos/" + $username + "/" + $Repo + "/git/trees/" + $commitSha;
    $treeData = Invoke-RestMethod -Method Get -Uri $Uri -Headers $headers;
    #get sha of the folder with runbooks
    $folderSha = $null;
    for ($i = 0; ($i -lt $treeData.tree.Count) -and ($folderSha -eq $null); $i++)
    {
        $item = $treeData.tree[$i];
        if (($item.path -eq $FolderPath) -and ($item.type -eq "tree"))
        {
            $folderSha = $item.sha;
        }
        $item = $null;
    }

    # get sha of folder's tree
    $Uri = "https://api.github.com/repos/" + $username + "/" + $Repo + "/git/trees/" + $folderSha;
    $folderTreeData = Invoke-RestMethod -Method Get -Uri $Uri -Headers $headers;
    
    $runbookInfo = InlineScript {        
        # recursively go through all nested folders and get runbooks data
        Function Sync-Folder {
            Param (
            [string] $FolderSha,
            [string] $OAuthToken,
            [string] $Username,
            [string] $Repo,
            $RbInfo
            )

            $result = $true;
            $headers = @{"Authorization" = "token $OAuthToken"};

            $Uri = "https://api.github.com/repos/" + $Username + "/" + $Repo + "/git/trees/" + $FolderSha;

                $folderData = Invoke-RestMethod -Method Get -Uri $Uri -Headers $headers;
                if ($folderData.truncated -eq "false")
                {
                   $result = $false;
                   Write-Verbose "Folder's data is truncated. Some files might not be synchronized"; 
                }
                
                foreach ($item in $folderData.tree)
                {
                    if (($item.type -eq "blob") -and ($item.path -match $psExtension))
                    {
                        # get name of the runbook
                        $pathSplit = $item.path.Split("/");
                        $filename = $pathSplit[$pathSplit.Count - 1];
                        $tempPathSplit = $filename.Split(".");
                        $runbookName = $tempPathSplit[0];

                        # get content of runbook
                        $itemSha = $item.sha;
                        $Uri = "https://api.github.com/repos/$username/$Repo/git/blobs/$itemSha";

                            $blobData = Invoke-RestMethod -Method Get -Uri $Uri -Headers $headers;
                            
                            # todo: if file's size is > 2MB (make a parameter maxSize)
                            $content = $blobData.content;
                            $bytes = [System.Convert]::FromBase64String($content);
                            $runbookDefinition = [System.Text.Encoding]::UTF8.GetString($bytes);
                            $runbookSize = $blobData.size;

                            Write-Verbose "Adding $runbookName with definition $runbookDefinition to hashtable. Size: $runbookSize"
                            $RbInfo.Add($runbookName, $runbookDefinition);
                    }
                    elseif ($item.type -eq "tree")
                    {
                        $result = $result -and (Sync-Folder -FolderSha $item.sha -OAuthToken $OAuthToken -Username $Username -Repo $Repo -RbInfo $RbInfo)
                    }
                }
                
            Return $result;
        }
        $RbInfo = @{};
        # get all runbooks from the folder
        Sync-Folder -folderSha $Using:folderTreeData.sha -OAuthToken $Using:OAuthToken -Username $Using:username -Repo $Using:Repo -RbInfo $RbInfo;
        $RbInfo
    }

    foreach ($rbName in $runbookInfo.Keys) 
    {
        $rbDefinition = $runbookInfo.$rbName
        Write-Verbose "Trying to save $rbName to the database. definition $rbDefinition"
        #Set-AutomationRunbook -Name $rbName -Definition $rbDefinition
    }
    Write-Verbose "Sync is finished"
} 
