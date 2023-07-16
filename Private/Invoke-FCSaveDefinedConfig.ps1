function Invoke-FCSaveDefinedConfig {
    Param
    (
       [Parameter(Mandatory=$true)]
       $Session_Headers_SAN,

       [Parameter(Mandatory=$true)]
       $SAN,

       [Parameter(Mandatory=$true)]
       $EffectiveConfigChecksum,

       [Parameter(Mandatory=$false,
       HelpMessage='Please specify log location.')]
       $LogFile = "C:\Users\Public\Documents\FibreChannelTools.txt"
    )

    # Set URLs
    $EffectiveConfigSaveActionUrl = "https://$SAN/rest/running/brocade-zone/effective-configuration/cfg-action/1"

    # Save Defined Config
    try {
        $Body = "<checksum>$EffectiveConfigChecksum</checksum>"
        
        Invoke-RestMethod $EffectiveConfigSaveActionUrl -Method Patch -Headers $Session_Headers_SAN -SkipCertificateCheck -Body $Body -ResponseHeadersVariable Resp_Headers -StatusCodeVariable Resp_HTTP_Status
        if ($Resp_HTTP_Status -eq 204) {
            Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN] Defined Config [$EffectiveConfigChecksum] saved. HTTP Response: [$Resp_HTTP_Status]" -LogFile $LogFile
        }
        else {
            Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Defined Config [$EffectiveConfigChecksum] save FAILED. Response: [$Resp_Headers]`nHTTP Response: [$Resp_HTTP_Status]" -LogFile $LogFile
            throw "[$SAN] Defined Config [$EffectiveConfigChecksum] save FAILED. HTTP Response: [$Resp_HTTP_Status]"
        }
    }
    catch {
        Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Defined Config [$EffectiveConfigChecksum] save FAILED. Response: [$Resp_Headers]`nHTTP Response: [$Resp_HTTP_Status]" -LogFile $LogFile
        throw "[$SAN] Defined Config [$EffectiveConfigChecksum] save FAILED. HTTP Response: [$Resp_HTTP_Status]. Error:`n[$_]"
    }

    return $true
}