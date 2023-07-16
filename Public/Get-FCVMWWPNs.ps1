function Get-FCVMWWPNs {
    Param
    (
        [Parameter(Mandatory=$true)]
        $ComputerName,
        [Parameter(Mandatory=$false)]
        $LogFile = "C:\Users\Public\Documents\FibreChannelTools.txt" 
    )
    try {
        $HyperVHost = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
           (Get-Item "HKLM:\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters").GetValue("HostName")
        }
        $VMWWPNs = Invoke-Command -ComputerName $HyperVHost -ScriptBlock {
           Param($VMName)
           $VMWWPNs = @()
           $WWPNsList = Get-VMFibreChannelHba -VMName $VMName | Select-Object WorldWidePortNameSetA,WorldWidePortNameSetB
           $WWPNs = $WWPNsList.WorldWidePortNameSetA + $WWPNsList.WorldWidePortNameSetB
           foreach($VMWWPN in $WWPNs) {
              if($VMWWPN -match "iSCSI") {
                 Invoke-FCLogToFile "[ERROR]" "[$ComputerName] iSCSI service detected. Only FC connectivity is allowed." $LogFile
                 throw "iSCSI service detected. Only FC connectivity is allowed."
              }
              $ProperWWPN = ($VMWWPN -replace '^(.{2})(.{2})(.{2})(.{2})(.{2})(.{2})(.{2})', '$1:$2:$3:$4:$5:$6:$7:').ToLower() # Format WWPNs by adding colons sign (:) after each 2 characters
              $VMWWPNs += $ProperWWPN
           }
           $VMWWPNs
        } -ArgumentList $ComputerName;
        Invoke-FCLogToFile "[INFO]" "[$ComputerName] SAN-1 Primary WWPN [$($VMWWPNs[0])], SAN-1 Secondary WWPN [$($VMWWPNs[2])], SAN-2 Primary WWPN [$($VMWWPNs[1])], SAN-2 Secondary WWPN [$($VMWWPNs[3])]" $LogFile
        Write-Host "[$ComputerName] SAN-1 Primary WWPN [$($VMWWPNs[0])]`n[$ComputerName] SAN-1 Secondary WWPN [$($VMWWPNs[2])]`n[$ComputerName] SAN-2 Primary WWPN [$($VMWWPNs[1])]`n[$ComputerName] SAN-2 Secondary WWPN [$($VMWWPNs[3])]" -ForegroundColor Green
    }
    catch {
        Invoke-FCLogToFile "[ERROR]" "[$ComputerName] Failed to get WWPNs." $LogFile
        throw "Failed to get [$ComputerName] WWPNs."
    }
    Write-Output $VMWWPNs
 }