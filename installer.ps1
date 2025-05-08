Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

# VERSION CONTROL SETUP
$CurrentVersion = "1.0.2"

function Show-CustomUpdateDialog {
    # Create the custom form
    $dialogForm = New-Object Windows.Forms.Form
    $dialogForm.Text = "Update Available"
    $dialogForm.Size = New-Object System.Drawing.Size(400, 200)
    $dialogForm.StartPosition = 'CenterScreen'
    $dialogForm.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $dialogForm.FormBorderStyle = 'FixedDialog'
    $dialogForm.MaximizeBox = $false
    $dialogForm.TopMost = $true

    # Message label
    $msgLabel = New-Object Windows.Forms.Label
    $msgLabel.Text = "A new version is available!`nCurrent: $CurrentVersion`nLatest: $latest`nDo you want to update?"
    $msgLabel.ForeColor = [System.Drawing.Color]::White
    $msgLabel.AutoSize = $true
    $msgLabel.Location = New-Object System.Drawing.Point(10, 10)
    $dialogForm.Controls.Add($msgLabel)

    # Yes button (update now)
    $yesButton = New-Object Windows.Forms.Button
    $yesButton.Text = "Yes"
    $yesButton.Size = New-Object System.Drawing.Size(100, 40)
    $yesButton.Location = New-Object System.Drawing.Point(40, 100)
    $yesButton.Add_Click({
        $dialogForm.Close()
        Update-ScriptNow
    })
    $dialogForm.Controls.Add($yesButton)

    # Later button (update after script close)
    $laterButton = New-Object Windows.Forms.Button
    $laterButton.Text = "Later"
    $laterButton.Size = New-Object System.Drawing.Size(100, 40)
    $laterButton.Location = New-Object System.Drawing.Point(150, 100)
    $laterButton.Add_Click({
        $dialogForm.Close()
        Update-AfterClose
    })
    $dialogForm.Controls.Add($laterButton)

    # Cancel button (no update)
    $cancelButton = New-Object Windows.Forms.Button
    $cancelButton.Text = "Cancel"
    $cancelButton.Size = New-Object System.Drawing.Size(100, 40)
    $cancelButton.Location = New-Object System.Drawing.Point(260, 100)
    $cancelButton.Add_Click({
        $dialogForm.Close()
    })
    $dialogForm.Controls.Add($cancelButton)

    # Show the custom dialog
    $dialogForm.ShowDialog()
}

# Replace this line in Check-ForUpdate with the new custom dialog:
if ($CurrentVersion -ne $latest) {
    Show-CustomUpdateDialog
}




function Get-LatestVersion {
    $versionUrl = "https://github.com/Usfis/General-Installer/blob/main/version.txt"
    try {
        return (Invoke-RestMethod -Uri $versionUrl -UseBasicParsing).Trim()
    } catch {
        return $null
    }
}

function Update-ScriptNow {
    $scriptUrl = "https://raw.githubusercontent.com/YourUser/YourRepo/main/installer.ps1"
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
    $scriptUrl = "https://raw.githubusercontent.com/YourUser/YourRepo/main/installer.ps1"
    $targetPath = $MyInvocation.MyCommand.Path

    @"
Start-Sleep -Seconds 2
Invoke-WebRequest -Uri '$scriptUrl' -OutFile '$targetPath' -UseBasicParsing -ErrorAction SilentlyContinue
"@ | Out-File -Encoding UTF8 -FilePath $tempScript

    schtasks /Create /SC ONCE /TN "DreamiiVoid_Update" /TR "powershell -ExecutionPolicy Bypass -File `"$tempScript`"" /ST 00:00 /RL HIGHEST /F > $null
    schtasks /Run /TN "DreamiiVoid_Update" > $null
}

if ($CurrentVersion -ne $latest) {
    Show-CustomUpdateDialog
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

function Offline_Roblox_Studio() {
    $obs_Form = New-Object Windows.Forms.Form
    $obs_Form.Text = "Offline Studio Manage Menu"
    $obs_Form.Size = New-Object System.Drawing.Size(500, 300)
    $obs_Form.StartPosition = 'CenterScreen'
    $obs_Form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $obs_Form.FormBorderStyle = 'FixedDialog'
    $obs_Form.MaximizeBox = $false
    $obs_Form.TopMost = $true

    $fullPacket = New-ModernButton "Full Packet" (New-Object Drawing.point(40, 50)) { FullPacketInstaller }
    $rbsAutomater = New-ModernButton "Automater" (New-Object Drawing.point(270, 50)) { AutomaterInstaller }
    $exitrbs = New-ModernButton "Exit" (New-Object Drawing.point(270, 140)) { $obs_Form.Close() }

    $obs_Form.Controls.AddRange(@($fullPacket, $rbsAutomater, $exitrbs))
    $obs_Form.ShowDialog()
}

# MAIN MENU BUTTONS
$oBS = New-ModernButton "Offline Studio" (New-Object Drawing.point(40, 50)) { Offline_Roblox_Studio }
$exitI = New-ModernButton "Exit" (New-Object Drawing.Point(270, 140)) { $mainForm.Close() }

$mainForm.Controls.AddRange(@($exitI, $oBS))

# Run update check first
Check-ForUpdate

# Then launch UI
$mainForm.ShowDialog()
