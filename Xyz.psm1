if ($Env:ONEIMENV -eq 'Dev') {
    $curdir = Split-Path -Parent $MyInvocation.MyCommand.Path
    [System.Io.Directory]::SetCurrentDirectory($curdir)
    [System.Reflection.Assembly]::LoadFile("$PSScriptRoot\NLog.dll")
    [NLog.LogManager]::Configuration = New-Object NLog.Config.XmlLoggingConfiguration("$PSScriptRoot\NLog.config")
} else {
    [System.Reflection.Assembly]::LoadFile('C:\Program Files\One Identity\One Identity Manager\NLog.dll')
}
$Log = [NLog.LogManager]::GetLogger('XyzConnectorLog')

$global:JsonFile = $null

$global:Data = @{
    'accounts' = @{}
}

# $global:Data = @{
#     'accounts' = @{
#         '001' = @{'id' = '001'; 'fname' = 'Alice'; 'lname' = 'Anderson'; 'title' = 'President';      'disabled' = '0'};
#         '002' = @{'id' = '002'; 'fname' = 'Bob';   'lname' = 'Brown';    'title' = 'Vice-president'; 'disabled' = '0'};
#         '003' = @{'id' = '003'; 'fname' = 'Carol'; 'lname' = 'Cooper';   'title' = 'CEO';            'disabled' = '0'};
#         '004' = @{'id' = '004'; 'fname' = 'David'; 'lname' = 'Davies';   'title' = 'CTO';            'disabled' = '0'}
#     }
# }

# Powershell 5.1 does not support "ConvertFrom-Json -As Hashtable"
# From https://github.com/POSHChef/POSHChef/blob/master/functions/Exported/ConvertFrom-JSONtoHashtable.ps1
function ConvertFrom-JsonToHashtable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)][AllowNull()][string]$InputObject,
        [switch]$casesensitive
    )
    if ([string]::IsNullOrEmpty($InputObject)) {
        $dict = @{}
    } else {
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
        $deserializer = New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer
        $deserializer.MaxJsonLength = [int]::MaxValue
        $dict = $deserializer.DeserializeObject($InputObject)
        if ($casesensitive -eq $false) {
            $dict = New-Object "System.Collections.Generic.Dictionary[System.String, System.Object]"($dict, [StringComparer]::OrdinalIgnoreCase)
        }
    }
    return $dict
}

function Connect-Xyz($file) {
    $Log.Info("Connect-Xyz file=$file")
    $global:JsonFile = $file
    if (Test-Path -Path $global:JsonFile -PathType Leaf) {
        $global:Data = Get-Content -Path $global:JsonFile | Out-String | ConvertFrom-JsonToHashtable
    }
}

function Disconnect-Xyz() {
    $Log.Info("Disconnect-Xyz")
    Set-Content -Path $global:JsonFile -Value (ConvertTo-Json $global:Data -Depth 100)
}

function Get-XyzAccounts() {
    $Log.Info('Get-XyzAccounts')
    $res = $global:Data['accounts'].Values |% { New-Object PSCustomObject -Property $_ }
    $Log.Debug("  > {0}" -f ($res | ConvertTo-Json -Compress))
    $res
}

function Get-XyzAccount($id) {
    $Log.Info("Get-XyzAccount id=$id")
    $res = New-Object PSCustomObject -Property $global:Data['accounts'][$id]
    $Log.Debug("  > {0}" -f ($res | ConvertTo-Json -Compress))
    $res
}

function New-XyzAccount($id, $fname, $lname, $title, $disabled = '0') {
    $Log.Info("New-XyzAccount id=$id fname=$fname lname=$lname title=$title disabled=$disabled")
    if (($null -eq $id) -or ('' -eq $id)) { $id = (New-Guid).Guid }
    $global:Data['accounts'][$id] = @{'id' = $id; 'fname' = $fname; 'lname' = $lname; 'title' = $title; 'disabled' = $disabled}
    $Log.Debug("  > id = $id")
    New-Object PSCustomObject -Property @{id = $id}
}

function Set-XyzAccount($id, $fname, $lname, $title) {
    $Log.Info("Set-XyzAccount id=$id fname=$fname lname=$lname title=$title")
    $Log.Debug("  * parameters = {0}" -f ($PSBoundParameters | ConvertTo-Json -Compress))
    $PSBoundParameters.Keys |? { $_ -in @('fname', 'lname', 'title') } |% { $global:Data['accounts'][$id][$_] = $PSBoundParameters[$_] }
}

function Set-XyzAccount2($id, $fname, $lname, $title) {
    $Log.Info("Set-XyzAccount2 id=$id fname=$fname lname=$lname title=$title")
    $Log.Debug("  * parameters = {0}" -f ($PSBoundParameters | ConvertTo-Json -Compress))
}

function Set-XyzAccountDisabled($id, $disabled) {
    $Log.Info("Set-XyzAccountDisabled id=$id disabled=$disabled")
    $global:Data['accounts'][$id]['disabled'] = $disabled
}

function Remove-XyzAccount($id) {
    $Log.Info("Remove-XyzAccount id=$id")
    $global:Data['accounts'].Remove($id) | Out-Null
}

Export-ModuleMember *-Xyz*
