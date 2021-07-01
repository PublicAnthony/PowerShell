$Parm1 = $args[0]
Write-Host $Parm1
$ServerNames=$args[0]

foreach ($ServerName in $ServerNames)
{
$result=invoke-command -ComputerName $ServerName -ScriptBlock {get-smbshare }
$result |FL PSComputerName,Name,Path
}