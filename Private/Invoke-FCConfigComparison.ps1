function Invoke-FCConfigComparison {
    Param
    (
       [Parameter(Mandatory=$true)]
       $InitialConfig,

       [Parameter(Mandatory=$true)]
       $FinalConfig,

       [Parameter(Mandatory=$true)]
       $EffectiveConfigName,

       [Parameter(Mandatory=$true)]
       $SAN,

       [Parameter(Mandatory=$true)]
       $WWPNs,

       [Parameter(Mandatory=$false,
       HelpMessage='Please specify config to check.')]
        [ValidateSet("DeffinedConfig", "EffectiveConfig")]
        [string[]]$ConfigToCheck,

       [Parameter(Mandatory=$false,
       HelpMessage='Please specify log location.')]
       $LogFile = "C:\Users\Public\Documents\FibreChannelTools.txt"
    )

    try {
        if ($ConfigToCheck -eq "DeffinedConfig") {
            $InitialDefinedConfigZones = $InitialConfig.SelectNodes("//defined-configuration//cfg[cfg-name='$EffectiveConfigName']//member-zone//zone-name")
            $FinalDefinedConfigZones = $FinalConfig.SelectNodes("//defined-configuration//cfg[cfg-name='$EffectiveConfigName']//member-zone//zone-name")

            $InitialDefinedConfigZonesEntries = $InitialDefinedConfigZones | select-object -ExpandProperty InnerText
            $FinalDefinedConfigZonesEntries = $FinalDefinedConfigZones | select-object -ExpandProperty InnerText
    
            $DefinedConfigDrifts = Compare-Object -ReferenceObject $InitialDefinedConfigZonesEntries -DifferenceObject $FinalDefinedConfigZonesEntries
    
            if ($DefinedConfigDrifts) {
                foreach($ZoneEntry in $DefinedConfigDrifts) {
                    if ($ZoneEntry.SideIndicator -eq "<=") {
                        Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Zone [$($ZoneEntry.InputObject)] is in Initial Defined Configuration but not in Final Defined Configuration!!!" -LogFile $LogFile
                        $ConfigCecksResult = "0"
                    }
                    elseif ($ZoneEntry.SideIndicator -eq "=>") {
                        if ($ZoneEntry.InputObject -eq $PeerZoneName) {
                            Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN] Zone [$($ZoneEntry.InputObject)] is a new Zone and it is expected" -LogFile $LogFile
                            $ConfigCecksResult = "1"
                        } else {
                            Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Zone [$($ZoneEntry.InputObject)] is in Final Defined Configuration but not in Initial Defined Configuration and it is something new: [$($ZoneEntry.InputObject)]" -LogFile $LogFile
                            $ConfigCecksResult = "0"
                        }
                    }
                }
            } else {
                Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN] No Zone Drifts found between Initial and Final Defined Configuration. Seems nothing has been changed." -LogFile $LogFile
                $ConfigCecksResult = "2"
            }
        }
        if ($ConfigToCheck -eq "EffectiveConfig") {
            $InitialEffectiveConfigZones = $InitialConfig.SelectNodes("//effective-configuration//enabled-zone//zone-name")
            $FinalEffectiveConfigZones = $FinalConfig.SelectNodes("//effective-configuration//enabled-zone//zone-name")

            $InitialEffectiveConfigZonesEntries = $InitialEffectiveConfigZones | select-object -ExpandProperty InnerText
            $FinalEffectiveConfigZonesEntries = $FinalEffectiveConfigZones | select-object -ExpandProperty InnerText
    
            $EffectiveConfigDrifts = Compare-Object -ReferenceObject $InitialEffectiveConfigZonesEntries -DifferenceObject $FinalEffectiveConfigZonesEntries
    
            if ($EffectiveConfigDrifts) {
                foreach($ZoneEntry in $EffectiveConfigDrifts) {
                    if ($ZoneEntry.SideIndicator -eq "<=") {
                        Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Zone [$($ZoneEntry.InputObject)] is in Initial Effective Configuration but not in Final Effective Configuration!!!" -LogFile $LogFile
                        $ConfigCecksResult = "0"
                    }
                    elseif ($ZoneEntry.SideIndicator -eq "=>") {
                        if ($ZoneEntry.InputObject -eq $PeerZoneName) {
                            Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN] Zone [$($ZoneEntry.InputObject)] is a new Zone and it is expected" -LogFile $LogFile
                            $ConfigCecksResult = "1"
                        } else {
                            Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Zone [$($ZoneEntry.InputObject)] is in Final Effective Configuration but not in Initial Effective Configuration and it is something new: [$($ZoneEntry.InputObject)]" -LogFile $LogFile
                            $ConfigCecksResult = "0"
                        }
                    }
                }
            } else {
                Write-Host "[$SAN] There are no differences between Initial Effective Configuration and Final Effective Configuration. Seems you haven't activated new configuration yet." -ForegroundColor Green
                Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN] There are no differences between Initial Effective Configuration and Final Effective Configuration. Seems you haven't added new zones into Active confir or haven't activated new configuration yet." -LogFile $LogFile
                $ConfigCecksResult = "2"
            }
        }
    }

    catch {
        Write-Host "[$SAN] Error during Configurartion Comparison: $_" -ForegroundColor Red
        Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Error during Configurartion Comparison. Error: $_ " -LogFile $LogFile
        throw "[$SAN] Error during Configurartion Comparison. Error: $_ "
    }
    
    return $ConfigCecksResult
}