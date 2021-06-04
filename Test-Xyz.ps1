$Env:ONEIMENV = 'Dev'
Import-Module -Force .\Xyz.psm1

Connect-Xyz 'Xyz.json'

Get-XyzAccounts | Out-Null

Set-XyzAccount -id '43e2aa57-40bb-4ce3-b3f5-4de55750bccf' -title 'Big boss'
Get-XyzAccount -id '43e2aa57-40bb-4ce3-b3f5-4de55750bccf' | Out-Null

Set-XyzAccount -id '43e2aa57-40bb-4ce3-b3f5-4de55750bccf' -title 'President'
Get-XyzAccount -id '43e2aa57-40bb-4ce3-b3f5-4de55750bccf' | Out-Null

New-XyzAccount -id 'e73e0c29-a959-4498-9509-96fc3c8dff9b' -fname 'Erin' -lname 'Evans' -title 'Sysadmin' | Out-Null
Get-XyzAccounts | Out-Null

Set-XyzAccountDisabled -id 'e73e0c29-a959-4498-9509-96fc3c8dff9b' -disabled '1'
Get-XyzAccount         -id 'e73e0c29-a959-4498-9509-96fc3c8dff9b' | Out-Null

Set-XyzAccountDisabled -id 'e73e0c29-a959-4498-9509-96fc3c8dff9b' -disabled '0'
Get-XyzAccount         -id 'e73e0c29-a959-4498-9509-96fc3c8dff9b' | Out-Null

Remove-XyzAccount -id 'e73e0c29-a959-4498-9509-96fc3c8dff9b'
Get-XyzAccounts | Out-Null

Disconnect-Xyz
