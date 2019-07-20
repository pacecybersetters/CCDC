$Agent = Read-Host -Prompt 'Agent Name'
$Date = (Get-Date).ToString('MM.dd.yyyy')

$Title = 'System Inventory Report' 
 
$AgentHeading = "Created by $Agent"

$DateHeading = "Date Created: $Date"

$Srvc = Get-Service | Sort-Object -Property Status, DisplayName | Format-Table @{L='Display Name';E={$_.DisplayName}}, Status #| Out-File -FilePath E:\Process-ServicesInventory-$Date.txt -Append
$Prcs = tasklist -V 
$hstnme = (Get-WmiObject Win32_OperatingSystem).CSName
$hstos = (Get-WmiObject Win32_OperatingSystem).Caption 
$hstarc = (Get-WmiObject Win32_OperatingSystem).OSArchitecture
$hstosversion = (Get-WmiObject Win32_OperatingSystem).Version
$instSoft = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Sort-Object Publisher, DisplayName, DisplayVersion, InstallDate | Format-Table –AutoSize 
$localusr = Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount='True'" | Select PSComputername, Name, Status, Disabled, AccountType, Lockout, PasswordRequired, PasswordChangeable, SID | Format-Table –AutoSize 


Write-Output "---------------------------------------------------"
Write-Output "              $Title               " 
Write-Output "---------------------------------------------------"
Write-Output " "

Write-Output $AgentHeading  
Write-Output $DateHeading  
Write-Output " "

Write-Output "---------------------------------------------------"
Write-Output "          Operating System Information            " 
Write-Output "---------------------------------------------------"
Write-Output " "

Write-Output "Operating System: $hstos $hstarc"
Write-Output "Version Number: $hstosversion"
Write-Output "Computer Name: $hstnme"
Write-Output " "


Write-Output "                Installed Services                 " 
Write-Output "---------------------------------------------------"
Write-Output " "
Write-Output $Srvc  
Write-Output " "
Write-Output "                Running Processes                  " 
Write-Output "---------------------------------------------------"
Write-Output " "
Write-Output $Prcs 
Write-Output " "
Write-Output "                Installed Software                  " 
Write-Output "---------------------------------------------------"
Write-Output " "
Write-Output $instSoft
Write-Output " "

Write-Output "---------------------------------------------------"
Write-Output "                 User Information                  " 
Write-Output "---------------------------------------------------"
Write-Output " "

Write-Output "                Local User Accounts                " 
Write-Output "---------------------------------------------------"
Write-Output " "

Write-Output $localusr


Write-Output "              User Accounts by Group               " 
Write-Output "---------------------------------------------------"
Write-Output " "

function Get-Accounts { 
$localadmgrp = net localgroup administrators | 
 where {$_ -AND $_ -notmatch "command completed successfully"} | 
 select -skip 4
New-Object PSObject -Property @{
 Computername = $env:COMPUTERNAME
 Group = "Administrators"
 Members=$localadmgrp
 }

$localusrgrp = net localgroup users | 
 where {$_ -AND $_ -notmatch "command completed successfully"} | 
 select -skip 4
New-Object PSObject -Property @{
 Computername = $env:COMPUTERNAME
 Group = "Users"
 Members = $localusrgrp
 }

 $localrmtdskgrp = net localgroup "Remote Desktop Users"| 
 where {$_ -AND $_ -notmatch "command completed successfully"} | 
 select -skip 4
New-Object PSObject -Property @{
 Computername = $env:COMPUTERNAME
 Group = "Remote Desktop Users"
 Members = $localrmtdskgrp
 }

 $localrmtmntgrp = net localgroup "Remote Management Users"| 
 where {$_ -AND $_ -notmatch "command completed successfully"} | 
 select -skip 4
New-Object PSObject -Property @{
 Computername = $env:COMPUTERNAME
 Group = "Remote Management Users"
 Members = $localrmtmntgrp
 }

 $localsmagrp = net localgroup "System Managed Accounts Group"| 
 where {$_ -AND $_ -notmatch "command completed successfully"} | 
 select -skip 4
New-Object PSObject -Property @{
 Computername = $env:COMPUTERNAME
 Group = "System Managed Accounts Group"
 Members = $localsmagrp
 }

 $localpowusrgrp = net localgroup "Power Users"| 
 where {$_ -AND $_ -notmatch "command completed successfully"} | 
 select -skip 4
New-Object PSObject -Property @{
 Computername = $env:COMPUTERNAME
 Group = "Power Users"
 Members = $localpowusrgrp
 }

  $localgstgrp = net localgroup "Guests"| 
 where {$_ -AND $_ -notmatch "command completed successfully"} | 
 select -skip 4
New-Object PSObject -Property @{
 Computername = $env:COMPUTERNAME
 Group = "Guests"
 Members = $localgstgrp
 }

 }

Get-Accounts

Write-Output " "
Write-Output "                 Logged on Users                   " 
Write-Output "---------------------------------------------------"
Write-Output " "

query USER

Write-Output "---------------------------------------------------"
Write-Output "              Networking Information               " 
Write-Output "---------------------------------------------------"
Write-Output " "

Write-Output " "
Write-Output "              IPAddress Information                " 
Write-Output "---------------------------------------------------"
Write-Output " "

Get-NetIPAddress | Sort-Object -Property AddressFamily,AddressState |Format-Table -Property IPAddress,AddressFamily,InterfaceAlias,AddressState,InterfaceIndex -AutoSize 


Write-Output " "
Write-Output "              MACAddress Information                " 
Write-Output "---------------------------------------------------"
Write-Output " "

Get-WmiObject win32_networkadapterconfiguration | Format-List -Property Caption,IPAddress,MACAddress

Write-Output " "
Write-Output "                  Routing Table                    " 
Write-Output "---------------------------------------------------"
Write-Output " "

Get-NetRoute |Sort-Object -Descending -Property AddressFamily,NextHop,InterfaceAlias | Format-Table -Property AddressFamily,State,ifIndex,InterfaceAlias,NextHop

Write-Output " "
Write-Output "                   Open Ports                      " 
Write-Output "---------------------------------------------------"
Write-Output " "

Get-NetTCPConnection | Sort-Object -Property State,RemoteAddress

Write-Output " "
Write-Output "                  Firewall Rules                   " 
Write-Output "---------------------------------------------------"
Write-Output " "

Get-NetFirewallRule -PolicyStore ActiveStore | Format-Table -Property DisplayName,Enabled,Direction,Owner,PolicyStoreSource

cat C:\Windows\System32\drivers\etc\hosts