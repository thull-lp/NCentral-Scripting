
# Set Regex & Known Folder Path
$Regex = '^[\d,A-Z]{6,10}$'
$FolderPath = "C:\ProgramData"

# Get a list of folders and suspicious folders
$DirectoryList = Get-ChildItem $FolderPath -Force | Where-Object {$_.PSIsContainer -eq $True}
$DirtyFolderList = $DirectoryList -cmatch $Regex

# Perform check
If ($Null -ne $DirtyFolderList){
    # Set flag
    $FolderFound = $True
    # Iterate list of suspicious folders
    ForEach ($DirtyFolder in $DirtyFolderList){
        # Check for any .dll files
        $DLLPath = Join-Path $FolderPath $DirtyFolder.Name
        $DLLFiles = Get-ChildItem -Force $DLLPath -Filter *.dll
        $DLLFilesCount = $DLLFiles.Count        
    }

    If (($DLLFilesCount -eq 0) -and ($FolderFound -eq $True)) {
        $Output = "A suspicious folder was found - $($DLLPath), please investigate or remove as necessary."
    }

    If (($DLLFilesCount -ge 1) -and ($FolderFound -eq $True)) {
        $Output = "A suspicious folder was found - $($DLLPath), and .dll files are present, this device may be infected or may have been infected but not completely cleaned up."
    }
} Else {
    $FolderFound = $False
    $DLLFilesCount = 0

    $Output = "No evidence of DanaBot present, no actions required."
}