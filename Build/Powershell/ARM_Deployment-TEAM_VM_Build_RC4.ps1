$ErrorActionPreference = "Stop"
$LabsPath = 'C:\_SQLHACK_'

##################################################################
#Create Folders for Labs and Installs
##################################################################
If(!(test-path $LabsPath))
{
    md -Path $LabsPath

    # Create Shortcut on desktop
    $TargetFile   = "C:\_SQLHACK_\"
    $ShortcutFile = "C:\Users\Public\Desktop\_SQLHACK_.lnk"
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut     = $WScriptShell.CreateShortcut($ShortcutFile)
    $Shortcut.TargetPath = $TargetFile
    $Shortcut.Save()
}

If(-not(Get-PackageProvider -Name Nuget -ListAvailable -ErrorAction silentlycontinue)){
    write-host "Nuget package not found - install now"
    Install-PackageProvider -Name Nuget -MinimumVersion 2.8.5.201 -Force
}

If(-not(Get-InstalledModule Az -ErrorAction silentlycontinue)){
    write-host "Az module not found - install now"
    Install-Module -Name Az -Repository PSGallery -Force -AllowClobber
    write-host "Az module installed"
    #Restart-Computer -Force
}
else {
    write-host "Az module already installed"
}


