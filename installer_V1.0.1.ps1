Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

# VERSION CONTROL SETUP
$CurrentVersion = "1.0.1"
$ScriptName = "GenInstaller_v$CurrentVersion.ps1"
$ScriptDirectory = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)

# Check for older versions in the same directory
function Check-OlderVersions {
    $files = Get-ChildItem -Path $ScriptDirectory -Filter "GenInstaller_v*.ps1"
    $olderVersions = $files | Where-Object { $_.Name -ne $ScriptName }
    
    if ($olderVersions.Count -gt 0) {
        $versionNames = $olderVersions | ForEach-Object { $_.Name }
        $msg = "Older versions found: `n$($versionNames -join "`n")`nDo you want to delete them?"
        $choice = [System.Windows.Forms.MessageBox]::Show($msg, "Delete Old Versions", [System.Windows.Forms.MessageBoxButtons]::YesNo)

        if ($choice -eq [System.Windows.Forms.DialogResult]::Yes) {
            $olderVersions | ForEach-Object { Remove-Item $_.FullName -Force }
            [System.Windows.Forms.MessageBox]::Show("Old versions deleted.", "Success")
        } else {
            # Remember the user's choice to not delete old versions
            $preferenceFile = "$ScriptDirectory\deleteOldVersionsPreference.txt"
            if (-not (Test-Path $preferenceFile)) {
                "Do not ask about deleting older versions again." | Out-File -FilePath $preferenceFile
            }
        }
    }
}

function Get-LatestVersion {
    $versionUrl = "https://raw.githubusercontent.com/Usfis/General-Installer/main/version.txt"
    try {
        return (Invoke-RestMethod -Uri $versionUrl -UseBasicParsing).Trim()
    } catch {
        return $null
    }
}

function Update-ScriptNow {
    $scriptUrl = "https://raw.githubusercontent.com/Usfis/General-Installer/main/installer.ps1"
    $myPath = $MyInvocation.MyCommand.Path
    try {
        Invoke-WebRequest -Uri $scriptUrl -OutFile $myPath -UseBasicParsing -ErrorAction Stop
        [System.Windows.Forms.MessageBox]::Show("Script successfully updated to the latest version.", "Update Complete")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Update failed: $_", "Error")
    }
}

function Update-AfterClose {
    $tempScript = "$env:TEMP\Dreamii_Update.ps1"
    $scriptUrl = "https://raw.githubusercontent.com/Usfis/General-Installer/main/installer.ps1"
    $targetPath = $MyInvocation.MyCommand.Path

    @"
Start-Sleep -Seconds 2
Invoke-WebRequest -Uri '$scriptUrl' -OutFile '$targetPath' -UseBasicParsing -ErrorAction SilentlyContinue
"@ | Out-File -Encoding UTF8 -FilePath $tempScript

    schtasks /Create /SC ONCE /TN "DreamiiVoid_Update" /TR "powershell -ExecutionPolicy Bypass -File `"$tempScript`"" /ST 00:00 /RL HIGHEST /F > $null
    schtasks /Run /TN "DreamiiVoid_Update" > $null
}

function Check-ForUpdate {
    $latest = Get-LatestVersion
    if (-not $latest) { return }

    if ($CurrentVersion -ne $latest) {
        $msg = "A new version is available!`nCurrent: $CurrentVersion`nLatest: $latest`nDo you want to update?"
        $choice = [System.Windows.Forms.MessageBox]::Show($msg, "Update Available", [System.Windows.Forms.MessageBoxButtons]::YesNoCancel)

        switch ($choice) {
            "Yes" { Update-ScriptNow }
            "No"  { Update-AfterClose }
            default { return }
        }
    }
}

# GUI SETUP
$mainForm = New-Object Windows.Forms.Form
$mainForm.Text = "DreamiiVoid Inc. Manage Menu"
$mainForm.Size = New-Object System.Drawing.Size(500, 300)
$mainForm.StartPosition = 'CenterScreen'
$mainForm.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$mainForm.FormBorderStyle = 'FixedDialog'
$mainForm.MaximizeBox = $false
$mainForm.TopMost = $true

function New-ModernButton($text, $location, $onclick) {
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $text
    $button.Size = New-Object System.Drawing.Size(180, 50)
    $button.Location = $location
    $button.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
    $button.ForeColor = [System.Drawing.Color]::White
    $button.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Regular)
    $button.FlatStyle = 'Flat'
    $button.FlatAppearance.BorderSize = 0
    $button.Add_Click($onclick)
    return $button
}

function FullPacketInstaller() {
    $savePath = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($savePath.ShowDialog() -eq 'OK') {
        $downloadPath = $savePath.SelectedPath
        [System.Windows.Forms.MessageBox]::Show("Reminder: You should verify the code before running any downloaded scripts!", "Warning")

        # Placeholder for actual download
        $url = "https://github.com/YourUser/YourRepo/releases/download/latest/OfflineRobloxFullPacket.zip"
        $zipDest = Join-Path $downloadPath "OfflineRobloxFullPacket.zip"

        Invoke-WebRequest -Uri $url -OutFile $zipDest -UseBasicParsing
        Expand-Archive -LiteralPath $zipDest -DestinationPath $downloadPath -Force
        Remove-Item $zipDest
        [System.Windows.Forms.MessageBox]::Show("Full Packet Installed.", "Done")
    }
}

function AutomaterInstaller () {
    $savePath = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($savePath.ShowDialog() -eq 'OK') {
        $downloadPath = $savePath.SelectedPath
        [System.Windows.Forms.MessageBox]::Show("Reminder: You should verify the code before running any downloaded scripts!", "Warning")

        $url = "https://github.com/YourUser/YourRepo/releases/download/latest/RobloxAutoScript.zip"
        $zipDest = Join-Path $downloadPath "RobloxAutoScript.zip"

        Invoke-WebRequest -Uri $url -OutFile $zipDest -UseBasicParsing
        Expand-Archive -LiteralPath $zipDest -DestinationPath $downloadPath -Force
        Remove-Item $zipDest
        [System.Windows.Forms.MessageBox]::Show("Automater Installed.", "Done")
    }
}

# MAIN MENU BUTTONS
$oBS = New-ModernButton "Offline Studio" (New-Object Drawing.point(40, 50)) { Offline_Roblox_Studio }
$exitI = New-ModernButton "Exit" (New-Object Drawing.Point(270, 140)) { $mainForm.Close() }

$mainForm.Controls.AddRange(@($exitI, $oBS))

# Run update check first
Check-ForUpdate

# Then launch UI
$mainForm.ShowDialog()
