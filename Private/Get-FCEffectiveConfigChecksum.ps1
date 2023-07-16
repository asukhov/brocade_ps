function Get-FCEffectiveConfigChecksum {
    Param
    (
       [Parameter(Mandatory=$true)]
       $Session_Headers_SAN,

       [Parameter(Mandatory=$true)]
       $SAN,

       [Parameter(Mandatory=$false,
       HelpMessage='Please specify log location.')]
       $LogFile = "C:\Users\Public\Documents\FibreChannelTools.txt"
    )

    # Set URLs
    $EffectiveConfigUrlSAN = "https://$SAN/rest/running/brocade-zone/effective-configuration/checksum"

    # Get Effective Configuration Checksum
    try {
        $ResponseEffectiveConfigSAN = Invoke-RestMethod $EffectiveConfigUrlSAN -Method Get -Headers $Session_Headers_SAN -SkipCertificateCheck -ResponseHeadersVariable Resp_Headers_EffCfg_SAN -StatusCodeVariable Resp_HTTP_Status_EffCfg_SAN
        Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN] Effective Configuration GET SUCCESS. HTTP Response: [$Resp_HTTP_Status_EffCfg_SAN] Effective Configuration:`n[$($ResponseEffectiveConfigSAN.OuterXml)]" -LogFile $LogFile
    }
    catch {
        Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Effective Configuration GET FAILED. Response: [$Resp_Headers_EffCfg_SAN]`nHTTP Response: [$Resp_HTTP_Status_EffCfg_SAN]" -LogFile $LogFile
        throw "[$SAN] Effective Configuration GET FAILED. Response: [$Resp_Headers_EffCfg_SAN]`nHTTP Response: [$Resp_HTTP_Status_EffCfg_SAN]"
    }

    try {
        $EffectiveConfigChecksum = $ResponseEffectiveConfigSAN.Response."effective-configuration".checksum
        Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN] Effective Configuration Checksum: [$EffectiveConfigChecksum]" -LogFile $LogFile
    }
    catch {
        Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Effective Configuration Checksum GET FAILED. Response: [$Resp_Headers_EffCfg_SAN]`nHTTP Response: [$Resp_HTTP_Status_EffCfg_SAN]" -LogFile $LogFile
        throw "[$SAN] Effective Configuration Checksum GET FAILED. Response: [$Resp_Headers_EffCfg_SAN]`nHTTP Response: [$Resp_HTTP_Status_EffCfg_SAN]"
    }

    return $EffectiveConfigChecksum
}