Param(
[Parameter(ValueFromPipeline=$True, Mandatory=$True)]
[Array] $Computers,
[Parameter(ValueFromPipeline=$True, Mandatory=$True, ValueFromPipelineByPropertyName=$true)]
[ValidateNotNullOrEmpty()]
[System.String] $Path
)

Function Class-Size($size)
{
IF($size -ge 1GB)
{
"{0:n2}" -f  ($size / 1GB) + " GB"
}
ELSEIF($size -ge 1MB)
{
"{0:n2}" -f  ($size / 1MB) + " MB"
}
ELSE
{
"{0:n2}" -f  ($size / 1KB) + " KB"
}
} 

function Get-FolderSize 
{
Param(
$Path, [Array]$Computers
) 
$Array = @()
Foreach($Computer in $Computers)
    {
    $ErrorActionPreference = "SilentlyContinue"

$Length = Invoke-Command -ComputerName $Computer -ScriptBlock {(Get-ChildItem $args[0] -Recurse | Measure-Object -Property Length -Sum).Sum } -ArgumentList $Path

#$Result = "" | Select Computer,Folder,Length,CreationTime,LastAccessTime,LastWriteTime,@{name="Owner";expression={(Get-Acl $Path).owner}}
$Result = "" | Select Computer,Folder,Length,@{name="CreationTime";expression={(Get-ItemProperty $Path).CreationTime}},@{name="LastAccessTime";expression={(Get-ItemProperty $Path).LastAccessTime}},@{name="LastWriteTime";expression={(Get-ItemProperty $Path).LastWriteTime}},@{name="Owner";expression={(Get-Acl $Path).owner}}

$Result.Computer = $Computer
$Result.Folder = $Path
$Result.Length = Class-Size $length
$Result.CreationTime = $Result.CreationTime 
$Result.LastAccessTime = $Result.LastAccessTime
$Result.LastWriteTime = $Result.LastWriteTime
$Result.Owner = $Result.Owner
$array += $Result

}

return $array
}


#$Paths = "c:\temp"
$ReportPath = "c:\temp\dropbox\test"
$Filename="RemoteServerSingePath"
$Pre = "<h1>Folder Sizes Report </h1><h3>Folders processed: </h3>"
$Post = "<h2><p>Total Items Processed: $NumDirs<br>Total Space Used:  $TotalSize</p></h2>Run on $(Get-Date -f 'MM/dd/yyyy hh:mm:ss tt')</body></html>"




$Results =Get-FolderSize -Computers $Computers -Path $Path 
Write-Host $Results
$Results| ConvertTo-Html -PreContent $Pre -PostContent $Post -Head $Header | Out-File $ReportPath\$Filename.html
$Results| Export-Csv -Path $ReportPath\$Filename.csv


#Display the report in your default browser
& $ReportPath\$Filename.html