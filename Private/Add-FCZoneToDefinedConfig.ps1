function Add-FCZoneToDefinedConfig {
    Param
    (
       [Parameter(Mandatory=$true)]
       $Session_Headers_SAN,

       [Parameter(Mandatory=$true)]
       $SAN,

       [Parameter(Mandatory=$true)]
       $ConfigName,

       [Parameter(Mandatory=$true)]
       $ZoneNames,

       [Parameter(Mandatory=$false,
       HelpMessage='Please specify log location.')]
       $LogFile = "C:\Users\Public\Documents\FibreChannelTools.txt"
    )

    # Set URLs
    $DefinedConfigUrl = "https://$SAN/rest/running/brocade-zone/defined-configuration/cfg"

    # Generate Body
    $ZoneNamesOutput = @()
    foreach($ZoneName in $ZoneNames){
        $ZoneNamesOutput += "`n<zone-name>$ZoneName</zone-name>`n"
    }

    # Add Zone to Defined Config
    try {
        $Body = "<cfg>
        `n<cfg-name>$ConfigName</cfg-name>
        `n<member-zone>
        $ZoneNamesOutput
        `n</member-zone>
        `n</cfg>"
        
        Invoke-RestMethod $DefinedConfigUrl -Method Post -Headers $Session_Headers_SAN -SkipCertificateCheck -Body $Body -ResponseHeadersVariable Resp_Headers -StatusCodeVariable Resp_HTTP_Status
        if ($Resp_HTTP_Status -eq 201) {
            Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN] Zone(s) [$ZoneNames] added to Defined Config [$ConfigName]. HTTP Response: [$Resp_HTTP_Status]" -LogFile $LogFile
        } else {
            Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Zone(s) [$ZoneNames] addition to Defined Config [$ConfigName] FAILED. HTTP Response: [$Resp_HTTP_Status]." -LogFile $LogFile
            throw "[$SAN] Zone(s) [$ZoneNames] addition to Defined Config [$ConfigName] FAILED. HTTP Response: [$Resp_HTTP_Status]"
        }
    }
    catch {
        Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Zone(s) [$ZoneNames] addition to Defined Config [$ConfigName] FAILED. Error:`n[$_]" -LogFile $LogFile
        throw "[$SAN] Zone(s) [$ZoneNames] addition to Defined Config [$ConfigName] FAILED. HTTP Response: [$Resp_HTTP_Status]"
    }

    return $true
}