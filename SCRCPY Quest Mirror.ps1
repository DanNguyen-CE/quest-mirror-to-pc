# Oculus Quest Mirror to PC Setup Tool (v.2)
# By: Daniel Nguyen

# REQUIRES: ADB & scrcpy*
# *https://github.com/Genymobile/scrcpy (ADB included)

# OPTIONAL: Wireless Network


# ------ Script Editor Use Only -------
$stopColor = "Red";
$inputColor = "Green";
$notificationColor = "Cyan";
# ------ Script Editor Use Only -------


$ErrorActionPreference = "Stop"

Write-Host "[ Scrcpy Setup Script ] by: Daniel Nguyen" -ForegroundColor DarkGreen;
Write-Host "`nhttps://github.com/Genymobile/scrcpy";
Write-Host "`nOculus Quest Mirror to PC Setup Tool.`nPlease make sure you have the required programs and then follow the instructions shown on screen.";

Write-Host "`n[>] " -NoNewline -ForegroundColor $stopColor;
Write-Host "Please plug in Oculus Quest and make sure both devices are connected to the same network.`n`nThen, press any key to continue...";
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');

# Start ADB
Write-Host "`n[>] " -NoNewline -ForegroundColor $notificationColor;
Write-Host "Attempting to terminate any existing connections...";
adb kill-server; # Terminates any existing connections

Write-Host "`n[>] " -NoNewline -ForegroundColor $notificationColor;
Write-Host "Starting ADB server...";
adb start-server;

# Wired or Wireless
Write-Host "`n[>] " -NoNewline -ForegroundColor $inputColor;
Write-Host "Connect wirelessly via Wi-Fi? (Y or N): " -NoNewline;
$wiredSetting = Read-Host;

If ($wiredSetting -iLike "Y")
{
    # Get IP address
    Write-Host "`n[>] " -NoNewline -ForegroundColor $notificationColor;
    Write-Host "Getting IP address...";
    $IP = (adb shell ip route | Out-String) -match '(?<=src\s)(?<content>.*)'; # Use regex to get IP from output string.
    $IP = ($matches['content'] | Out-String).Trim(); # Clean up string.

    Write-Host "IP address found: " $IP;

    # Establish wireless connection
    Write-Host "`n[>] " -NoNewline -ForegroundColor $notificationColor;
    Write-Host "Establishing a wireless connection...";
    adb tcpip 5555;
    adb connect "$($IP):5555";
}

ElseIf ($wiredSetting -iNotLike "N")
{
    Write-Error "Error. Invalid Input.";
}

# Get user settings
Write-Host "`n[>] " -NoNewline -ForegroundColor $inputColor;
Write-Host "Input the desired maximum resolution (recommended: 720): " -NoNewline;
$maxRes = Read-Host;

Write-Host "`n[>] " -NoNewline -ForegroundColor $inputColor;
Write-Host "Input the desired bit rate (recommended: 8M): " -NoNewline;
$bitRate = Read-Host;

Write-Host "`n[>] " -NoNewline -ForegroundColor $inputColor;
Write-Host "Square crop the eye? This will reduce mirrored eye's FOV. (Y or N) " -NoNewline;
$squared = Read-Host;

If ($wiredSetting -iLike "Y")
{
    Write-Host "`n[>] " -NoNewline -ForegroundColor $stopColor;
    Write-Host "Please unplug Oculus Quest.`n`nThen, press any key to continue...`n";
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}

# Start screen mirroring
Write-Host "`n[>] " -NoNewline -ForegroundColor $notificationColor;
Write-Host "Now mirroring with scrcpy...";

If($squared -iLike "Y")
{
    scrcpy --crop 1200:1000:130:250 -m $maxRes -b $bitRate -n;
}
Else
{
    scrcpy --crop 1440:1600:0:0 -m $maxRes -b $bitRate -n;
}


# End ADB after scrcpy terminates
adb kill-server;

# Exit PowerShell
stop-process -Id $PID