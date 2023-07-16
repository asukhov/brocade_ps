function Invoke-FCLogToFile {
    Param
    (
       [Parameter(Mandatory=$true)]
       $LogMessageType,
       
       [Parameter(Mandatory=$true)]
       $LogMessage,
 
       [Parameter(Mandatory=$true)]
       $LogFile
    )
    Write-Output "$(Get-Date),$LogMessageType,""$LogMessage""" | Out-File $LogFile -Append
 }