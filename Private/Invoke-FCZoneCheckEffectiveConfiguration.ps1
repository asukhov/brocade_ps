function Invoke-FCZoneCheckEffectiveConfiguration {
    Param
    (
       [Parameter(Mandatory=$true)]
       $SAN,

       [Parameter(Mandatory=$true)]
       $InitialEffectiveConfig,

       [Parameter(Mandatory=$true)]
       $ZoneName,

       [Parameter(Mandatory=$false,
       HelpMessage='Please specify log location.')]

       $LogFile = "C:\Users\Public\Documents\FibreChannelTools.txt"
    )

    try {
        # Check if Zone exists

        $InitialEffectiveConfigZones = $InitialEffectiveConfig.SelectNodes("//effective-configuration//enabled-zone//zone-name")
        $InitialEffectiveConfigZonesEntries = $InitialEffectiveConfigZones | select-object -ExpandProperty InnerText
        $ZoneMatch = @()
        foreach($Zone in $InitialEffectiveConfigZonesEntries){
            if($Zone -eq $ZoneName) {
                $ZoneMatch += $Zone
                Write-Host "[$SAN] Zone matched by name found in Effective Config: [$ZoneName]. New WWPNs will be added to it." -ForegroundColor Yellow
                Invoke-FCLogToFile -LogMessageType"INFO" -LogMessage "[$SAN] Zone matched by name found in Effective Config: [$ZoneName]. New WWPNs will be added to it." -LogFile $LogFile
                return $ZoneMatch
            }
        }
        if($null -eq $ZoneMatch) {
            Write-Host "[$SAN] No existing zones [$ZoneName] were found. Zone will be created." -ForegroundColor Green
            Invoke-FCLogToFile -LogMessageType "INFO" -LogMessage "[$SAN] No existing zones [$ZoneName] were found. Zone will be created." -LogFile $LogFile
            return $ZoneMatch # No zones exists
        }
    } catch {
        Write-Host "[$SAN] Error occured while checking for existing zones. Please check." -ForegroundColor Red
        Invoke-FCLogToFile -LogMessageType "ERROR" -LogMessage "[$SAN] Error occured while checking for existing zones. Please check. Error: $_" -LogFile $LogFile
        throw "[$SAN] Error checking Zone [$ZoneName]. Error: $_"
    }
}